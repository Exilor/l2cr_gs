require "./game_crypt"
require "./client_stats"
require "../util/flood_protectors"

class GameClient
  include MMO::Client(GameClient)
  include Synchronizable

  @crypt = GameCrypt.new
  @char_slot_mapping = [] of CharSelectInfoPackage
  @auto_save_task : Concurrent::PeriodicTask?
  @cleanup_task : Concurrent::DelayedTask?
  getter state = State::CONNECTED
  getter stats = ClientStats.new
  getter start_time = Time.ms
  getter active_char_lock = Mutex.new
  getter(flood_protectors) { FloodProtectors.new(self) }
  property active_char : L2PcInstance?
  property additional_close_packet : GameServerPacket?
  property trace : Slice(Slice(Int32)) = Slice(Slice(Int32)).empty
  property! account_name : String
  property! session_id : SessionKey
  property? protocol_ok : Bool = false
  property? game_guard_ok : Bool = false
  property? detached : Bool = false

  def initialize(con : MMO::Connection(self)?)
    super

    @packet_queue = Channel(GameClientPacket).new(Config.client_packet_queue_size)

    interval = Config.char_store_interval * 60000
    if interval > 0
      @auto_save_task = ThreadPoolManager.schedule_general_at_fixed_rate(->auto_save_task, 300000, interval)
    end
  end

  def send_packet(gsp : GameServerPacket)
    if detached?
      return
    end

    if gsp.invisible?
      if pc = @active_char
        unless pc.override_see_all_players?
          return
        end
      end
    end

    connection.send_packet(gsp)

    gsp.client = self
    gsp.run_impl
  end

  def state=(new_state : State)
    if @state != new_state
      @state = new_state
      @packet_queue.@queue.try &.clear
    end
  end

  def get_char_selection(slot : Int) : CharSelectInfoPackage?
    @char_slot_mapping[slot]?
  end

  def char_selection=(chars : Enumerable(CharSelectInfoPackage))
    @char_slot_mapping.replace(chars)
  end

  def get_l2id_for_slot(slot : Int) : Int32
    if cip = get_char_selection(slot)
      return cip.l2id
    end

    warn { "#get_l2id_for_slot(#{slot}) failed." }
    -1
  end

  def load_char_from_disk(slot : Int) : L2PcInstance?
    l2id = get_l2id_for_slot(slot)
    return if l2id < 0

    if pc = L2World.get_player(l2id)
      debug { "#{pc} attempted a double login." }
      if client = pc.client
        client.close_now
      else
        pc.delete_me
      end

      return
    end

    begin
      if pc = L2PcInstance.load(l2id)
        pc.set_running
        pc.stand_up
        pc.refresh_overloaded
        pc.refresh_expertise_penalty
        pc.set_online_status(true, false)
      else
        error { "Could not restore char in slot #{slot}." }
      end
    rescue e
      error "Error while trying to restore a character:"
      error e
      close_now
    end

    pc
  end

  def mark_to_delete_char(slot : Int32) : Int32
    id = get_l2id_for_slot(slot)
    return -1 if slot < 0

    answer = 0

    begin
      sql = "SELECT clanId FROM characters WHERE charId=?"
      GameDB.query_each(sql, id) do |rs|
        clan_id = rs.read(Int32)
        if clan_id != 0
          if clan = ClanTable.get_clan(clan_id)
            if clan.leader_id == id
              answer = 2
            else
              answer = 1
            end
          else
            warn { "#mark_to_delete_char No clan with ID #{clan_id} found." }
          end
        end
      end
    rescue e
      error e
    end


    if answer == 0
      if Config.delete_days == 0
        GameClient.delete_char_by_l2id(id)
      else
        sql = "UPDATE characters SET deletetime=? WHERE charId=?"
        GameDB.exec(sql, Time.ms + (Config.delete_days * 86400000), id)
      end
    end

    answer
  end

  def mark_restored_char(slot : Int32)
    l2id = get_l2id_for_slot(slot)
    if l2id < 0
      return
    end

    begin
      GameDB.exec("UPDATE characters SET deletetime=0 WHERE charId=?", l2id)
    rescue e
      error e
    end

    # LogRecord
  end

  def self.delete_char_by_l2id(id : Int32)
    return if id < 0

    CharNameTable.remove_name(id)

    GameDB.transaction do |tr|
      tr.exec("DELETE FROM character_contacts WHERE charId=? OR contactId=?", id, id)
      tr.exec("DELETE FROM character_friends WHERE charId=? OR friendId=?", id, id)
      tr.exec("DELETE FROM character_hennas WHERE charId=?", id)
      tr.exec("DELETE FROM character_macroses WHERE charId=?", id)
      tr.exec("DELETE FROM character_quests WHERE charId=?", id)
      tr.exec("DELETE FROM character_quest_global_data WHERE charId=?", id)
      tr.exec("DELETE FROM character_recipebook WHERE charId=?", id)
      tr.exec("DELETE FROM character_shortcuts WHERE charId=?", id)
      tr.exec("DELETE FROM character_skills WHERE charId=?", id)
      tr.exec("DELETE FROM character_skills_save WHERE charId=?", id)
      tr.exec("DELETE FROM character_subclasses WHERE charId=?", id)
      tr.exec("DELETE FROM heroes WHERE charId=?", id)
      tr.exec("DELETE FROM olympiad_nobles WHERE charId=?", id)
      tr.exec("DELETE FROM seven_signs WHERE charId=?", id)
      tr.exec("DELETE FROM pets WHERE item_obj_id IN (SELECT object_id FROM items WHERE items.owner_id=?)", id)
      tr.exec("DELETE FROM item_attributes WHERE itemId IN (SELECT object_id FROM items WHERE items.owner_id=?)", id)
      tr.exec("DELETE FROM items WHERE owner_id=?", id)
      tr.exec("DELETE FROM merchant_lease WHERE player_id=?", id)
      tr.exec("DELETE FROM character_raid_points WHERE charId=?", id)
      tr.exec("DELETE FROM character_reco_bonus WHERE charId=?", id)
      tr.exec("DELETE FROM character_instance_time WHERE charId=?", id)
      tr.exec("DELETE FROM character_variables WHERE charId=?", id)
      tr.exec("DELETE FROM characters WHERE charId=?", id)
      if Config.allow_wedding
        tr.exec("DELETE FROM mods_wedding WHERE player1Id = ? OR player2Id = ?", id, id)
      end
    end
  end

  def close_now
    @detached = true
    close(Packets::Outgoing::ServerClose::STATIC_PACKET)
    sync do
      if @cleanup_task
        cancel_cleanup
      end

      @cleanup_task = ThreadPoolManager.schedule_general(->cleanup_task, 0)
    end
  rescue e # debug
    error e
  end

  def close(gsp : GameServerPacket?)
    unless con = @connection
      return
    end

    if tmp = @additional_close_packet
      con.close({tmp, gsp})
    else
      con.close(gsp)
    end
  end

  def cancel_cleanup
    if task = @cleanup_task
      task.cancel
      @cleanup_task = nil
    end
  end

  def enable_crypt : Bytes
    key = GameCrypt.sample
    @crypt.key = key
    key
  end

  def encrypt(buf : ByteBuffer, size : Int32) : Bool
    @crypt.encrypt(buf.slice, buf.pos, size)
    buf.pos += size
    true
  end

  def decrypt(buf : ByteBuffer, size : Int32) : Bool
    @crypt.decrypt(buf.slice, buf.pos, size)
    true
  end

  def execute(gcp : GameClientPacket)
    if stats.count_floods
      warn "Client disconnected (too many floods: #{stats.long_floods} long and #{stats.short_floods} short)."
      close_now
      return
    end

    if @packet_queue.full?
      if stats.count_queue_overflow
        warn "Client disconnected (too many queue overflows)."
        close_now
      else
        debug "@packet_queue is full."
        send_packet(Packets::Outgoing::ActionFailed::STATIC_PACKET)
      end

      return
    end

    @packet_queue.send(gcp)

    begin
      if @state.connected?
        if stats.processed_packets > 3
          if Config.packet_handler_debug
            warn "Client disconnected (too many packets in non-authed state)."
          end
          close_now
          return
        end
        ThreadPoolManager.execute_io_packet(self)
      else
        ThreadPoolManager.execute_packet(self)
      end
    rescue e # rejected execution error
      error e # unless ThreadPoolManager is shutting down.
    end
  end

  def call
    count = 0

    until @packet_queue.empty?
      unless packet = (@packet_queue.receive rescue nil)#?
        return
      end
      if @detached
        @packet_queue.close
        return
      end

      begin
        packet.run
      rescue e
        error "Error while running #{packet.class}."
        error e
      end
      count += 1
    end
  end

  def handle_cheat(punishment : String)
    if pc = @active_char
      Util.punish(pc, punishment)
      return true
    end

    warn { "Kicked for cheating: #{punishment}." }

    close_now

    false
  end

  def drop_packet : Bool
    if @detached
      debug "#drop_packet: returning true because @detached."
      return true
    end

    if stats.count_packet(@packet_queue.@queue.not_nil!.size)
      debug "#drop_packet: @stats.count_packet(@packet_queue.size) returned true."
      send_packet(Packets::Outgoing::ActionFailed::STATIC_PACKET)
      return true
    end

    stats.drop_packet
  end

  def on_disconnection
    ThreadPoolManager.execute_general -> do
      begin
        fast = true
        pc = @active_char
        if pc && !@detached
          @detached = true
          if offline_mode?(pc)
            pc.leave_party
            OlympiadManager.unregister_noble(pc)
            pc.summon.try &.restore_summon = true
            pc.summon.try &.unsummon(pc)
            pc.summon.try &.broadcast_npc_info(0)
            if Config.offline_set_name_color
              pc.appearance.name_color = Config.offline_name_color
              pc.broadcast_user_info
            end
            if pc.offline_start_time == 0
              pc.offline_start_time = Time.ms
            end

            info { "#{pc.name} entering offline mode." }
            # log accounting

            return
          end
          fast = !pc.in_combat? && !pc.locked?
        end

        clean_me(fast)
      rescue e
        error e
      end
    end
  end

  def on_forced_disconnection
    # log accounting
    warn "Disconnected abnormally."
  end

  def clean_me(fast : Bool)
    sync do
      unless @cleanup_task
        delay = fast ? 5 : 1500
        @cleanup_task = ThreadPoolManager.schedule_general(->cleanup_task, delay)
      end
    end
  end

  private def auto_save_task
    if pc = @active_char
      if pc.online?
        save_char_to_disk
        pc.summon.try &.store_me
      end
    end
  end

  def save_char_to_disk
    if pc = @active_char
      pc.store_me
      pc.store_recommendations
    end
  rescue e
    error e
  end

  private def cleanup_task
    if auto_save_task = @auto_save_task
      auto_save_task.cancel
      @auto_save_task = nil
    end

    if pc = @active_char
      if pc.locked?
        warn "cleanup_task: #{pc.name} is locked."
      end

      pc.client = nil
      if pc.online?
        pc.delete_me
        AntiFeedManager.on_disconnect(self)
      end
    end

    @active_char = nil
  rescue e
    error e
  ensure
    LoginServerClient.send_logout(@account_name)
  end

  def on_buffer_underflow
    if stats.count_underflow_exception
      error "Client disconnected (too many underflow exceptions)."
      close_now
      return
    end

    if @state.connected?
      if Config.packet_handler_debug
        error "Client disconnected (too many buffer underflows in non-authed state)."
      end
      close_now
    end
  end

  def on_unknown_packet
    if stats.count_unknown_packet
      error "Client disconnected (too many unknown packets)."
      close_now
      return
    end

    if @state.connected?
      if Config.packet_handler_debug
        error "Client disconnected (too many unknown packets in non-authed state)."
      end
      close_now
    end
  end

  def offline_mode?(pc : L2PcInstance) : Bool
    if pc.in_olympiad_mode?
      return false
    end

    if pc.festival_participant?
      return false
    end

    if pc.blocked_from_exit?
      return false
    end

    if pc.jailed?
      return false
    end

    if pc.vehicle
      return false
    end

    can_set_shop = false

    case pc.private_store_type
    when .sell?, .package_sell?, .buy?
      can_set_shop = Config.offline_trade_enable
    when .manufacture?
      can_set_shop = Config.offline_trade_enable
    else
      can_set_shop = Config.offline_trade_enable && pc.in_craft_mode?
    end

    if Config.offline_mode_in_peace_zone && !pc.inside_peace_zone?
      can_set_shop = false
    end

    can_set_shop
  end

  def to_log(io : IO)
    io << "GameClient("
    if pc = @active_char
      io << pc.name
    elsif con = @connection
      begin
        io << con.ip
      rescue
        io << "socket closed"
      end
    else
      io << "disconnected"
    end
    io << ')'
  end

  enum State : UInt8
    CONNECTED, AUTHED, JOINING, IN_GAME
  end
end

require "../models/actor/instance/l2_pc_instance"
