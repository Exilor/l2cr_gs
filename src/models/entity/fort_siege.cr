require "./clan_hall/siegable"
require "../../instance_managers/fort_siege_guard_manager"
require "../../enums/fort_teleport_who_type"

class FortSiege
  include Siegable
  include Packets::Outgoing
  include Loggable

  private DELETE_FORT_SIEGECLANS_BY_CLAN_ID = "DELETE FROM fortsiege_clans WHERE fort_id = ? AND clan_id = ?"
  private DELETE_FORT_SIEGECLANS = "DELETE FROM fortsiege_clans WHERE fort_id = ?"

  @siege_guard_manager : FortSiegeGuardManager?
  @siege_end : TaskExecutor::Scheduler::DelayedTask?
  @siege_restore : TaskExecutor::Scheduler::DelayedTask?
  @siege_start_task : TaskExecutor::Scheduler::DelayedTask?
  @attacker_clans = Concurrent::Array(L2SiegeClan).new

  getter commanders = Concurrent::Array(L2Spawn).new
  getter fort
  getter? in_progress = false

  def initialize(@fort : Fort)
    check_auto_task
    FortSiegeManager.add_siege(self)
  end

  def end_siege
    unless in_progress?
      return
    end

    @in_progress = false
    remove_flags
    unspawn_flags

    update_player_siege_state_flags(true)

    owner_id = -1
    if owner = fort.owner_clan?
      owner_id = owner.id
    end

    fort.zone.banish_foreigners(owner_id)
    fort.zone.active = false
    fort.zone.update_zone_status_for_characters_inside
    fort.zone.siege_instance = nil

    save_fort_siege
    clear_siege_clan
    remove_commanders

    fort.spawn_npc_commanders
    siege_guard_manager.unspawn_siege_guard
    fort.reset_doors

    task = ->schedule_suspicious_merchant_spawn
    delay = FortSiegeManager.suspicious_merchant_respawn_delay.to_i64 * 60 * 1000
    ThreadPoolManager.schedule_general(task, delay)
    set_siege_date_time(true)

    if task = @siege_end
      task.cancel
      @siege_end = nil
    end

    if task = @siege_restore
      task.cancel
      @siege_restore = nil
    end

    if fort.owner_clan? && fort.flag_pole.mesh_index == 0
      fort.visible_flag = true
    end

    info { "Siege of #{fort.name} fort finished." }

    OnFortSiegeFinish.new(self).async(fort)
  end

  def start_siege
    if in_progress?
      return
    end

    if task = @siege_start_task
      task.cancel
      fort.despawn_suspicious_merchant
      @siege_start_task = nil
    end

    if attacker_clans.empty?
      return
    end

    @in_progress = true

    load_siege_clan
    update_player_siege_state_flags(false)
    teleport_player(FortTeleportWhoType::Attacker, TeleportWhereType::TOWN)

    fort.despawn_npc_commanders
    spawn_commanders
    fort.reset_doors
    spawn_siege_guard
    fort.visible_flag = true
    fort.zone.siege_instance = self
    fort.zone.active = true
    fort.zone.update_zone_status_for_characters_inside

    task = ->schedule_end_siege_task
    delay = FortSiegeManager.siege_length.to_i64 * 60 * 1000
    @siege_end = ThreadPoolManager.schedule_general(task, delay)

    sm = SystemMessage.the_fortress_battle_s1_has_begun
    sm.add_castle_id(fort.residence_id)
    announce_to_player(sm)
    save_fort_siege

    info { "Siege of #{fort.name} fort started." }

    OnFortSiegeStart.new(self).async(fort)
  end

  def announce_to_player(sm)
    attacker_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |pc|
        pc.send_packet(sm)
      end
    end

    if owner = fort.owner_clan?
      clan = ClanTable.get_clan(fort.owner_clan.id).not_nil!
      clan.each_online_player do |pc|
        pc.send_packet(sm)
      end
    end
  end

  def announce_to_player(sm, s : String)
    sm.add_string(s)
    announce_to_player(sm)
  end

  def update_player_siege_state_flags(clear : Bool)
    attacker_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |pc|
        if clear
          pc.siege_state = 0
          pc.siege_side = 0
          pc.in_siege = false
          pc.stop_fame_task
        else
          pc.siege_state = 1
          pc.siege_side = fort.residence_id
          if in_zone?(pc)
            pc.in_siege = true
            arg1 = Config.fortress_zone_fame_task_frequency * 1000
            arg2 = Config.fortress_zone_fame_aquire_points
            pc.start_fame_task(arg1, arg2)
          end
        end

        pc.broadcast_user_info
      end
    end

    if owner = fort.owner_clan?
      clan = ClanTable.get_clan(fort.owner_clan.id).not_nil!
      clan.each_online_player do |pc|
        if clear
          pc.siege_state = 0
          pc.siege_side = 0
          pc.in_siege = false
          pc.stop_fame_task
        else
          pc.siege_state = 2
          pc.siege_side = fort.residence_id
          if in_zone?(pc)
            pc.in_siege = true
            arg1 = Config.fortress_zone_fame_task_frequency * 1000
            arg2 = Config.fortress_zone_fame_aquire_points
            pc.start_fame_task(arg1, arg2)
          end
        end

        pc.broadcast_user_info
      end
    end
  end

  def in_zone?(obj : L2Object) : Bool
    in_zone?(*obj.xyz)
  end

  def in_zone?(x : Int32, y : Int32, z : Int32) : Bool
    in_progress? && fort.in_zone?(x, y, z)
  end

  def attacker?(clan : L2Clan?) : Bool
    !!clan && !!get_attacker_clan(clan)
  end

  def defender?(clan : L2Clan?) : Bool
    !!clan && fort.owner_clan? == clan
  end

  def clear_siege_clan
    sql = "DELETE FROM fortsiege_clans WHERE fort_id=?"
    GameDB.exec(sql, fort.residence_id)

    if owner_clan = fort.owner_clan?
      sql = "DELETE FROM fortsiege_clans WHERE clan_id=?"
      GameDB.exec(sql, owner_clan.id)
    end

    attacker_clans.clear

    if in_progress?
      end_siege
    end

    if task = @siege_start_task
      task.cancel
      @siege_start_task = nil
    end
  rescue e
    error e
  end

  def clear_siege_date
    fort.siege_date.ms = 0
  end

  def attackers_in_zone : Array(L2PcInstance)
    players = [] of L2PcInstance

    attacker_clans.each do |siege_clan|
      clan = ClanTable.get_clan(siege_clan.clan_id).not_nil!
      clan.each_online_player do |pc|
        if pc.in_siege?
          players << pc
        end
      end
    end

    players
  end

  def players_in_zone
    fort.zone.players_inside
  end

  def owners_in_zone
    players = [] of L2PcInstance

    if owner_clan = fort.owner_clan?
      clan = ClanTable.get_clan(owner_clan.id).not_nil!
      if clan != fort.owner_clan?
        return players
      end

      clan.each_online_player do |pc|
        if pc.in_siege?
          players << pc
        end
      end
    end

    players
  end

  def killed_commander(instance : L2FortCommanderInstance)
    if @commanders.empty?
      return
    end

    if sp = instance.spawn?
      commanders = FortSiegeManager.get_commander_spawn_list(fort.residence_id)
      commanders.not_nil!.each do |sp2|
        if sp2.id == sp.id
          str = nil
          case sp2.message_id
          when 1
            str = NpcString::YOU_MAY_HAVE_BROKEN_OUR_ARROWS_BUT_YOU_WILL_NEVER_BREAK_OUR_WILL_ARCHERS_RETREAT
          when 2
            str = NpcString::AIIEEEE_COMMAND_CENTER_THIS_IS_GUARD_UNIT_WE_NEED_BACKUP_RIGHT_AWAY
          when 3
            str = NpcString::AT_LAST_THE_MAGIC_FIELD_THAT_PROTECTS_THE_FORTRESS_HAS_WEAKENED_VOLUNTEERS_STAND_BACK
          when 4
            str = NpcString::I_FEEL_SO_MUCH_GRIEF_THAT_I_CANT_EVEN_TAKE_CARE_OF_MYSELF_THERE_ISNT_ANY_REASON_FOR_ME_TO_STAY_HERE_ANY_LONGER
          else
            # [automatically added else]
          end


          if str
            say = Packets::Incoming::Say2::NPC_SHOUT
            npc_say = NpcSay.new(instance.l2id, say, instance.id, str)
            instance.broadcast_packet(npc_say)
          end
        end
      end
      @commanders.delete_first(sp)

      if @commanders.empty?
        spawn_flag(fort.residence_id)
        if task = @siege_restore # not set to nil?
          task.cancel
        end

        fort.doors.each do |door|
          if door.show_hp?
            next
          end

          door.open_me
        end

        fort.siege.announce_to_player(SystemMessageId::ALL_BARRACKS_OCCUPIED)
      elsif @siege_restore.nil?
        fort.siege.announce_to_player(SystemMessageId::SEIZED_BARRACKS)
        task = ->schedule_siege_restore
        delay = FortSiegeManager.countdown_length.to_i64 * 60 * 1000
        @siege_restore = ThreadPoolManager.schedule_general(task, delay)
      else
        fort.siege.announce_to_player(SystemMessageId::SEIZED_BARRACKS)
      end
    else
      warn { "#killed_commander: killed commander, but commander with id #{instance.id} is not registered for fort with id #{fort.residence_id}." }
    end
  end

  def killed_flag(flag : L2Npc?)
    unless flag
      return
    end

    attacker_clans.each &.remove_flag(flag)
  end

  def add_attacker(pc : L2PcInstance, check_conditions : Bool) : Int32
    unless clan = pc.clan
      return 0
    end

    if check_conditions
      case
      when fort.siege.attacker_clans.empty? && pc.inventory.adena < 250000
        return 1
      when Time.ms < TerritoryWarManager.tw_start_time_in_millis && TerritoryWarManager.registration_over?
        return 2
      when Time.ms > TerritoryWarManager.tw_start_time_in_millis && TerritoryWarManager.tw_channel_open?
        return 2
      end

      FortManager.forts.each do |f|
        siege = f.siege
        if siege.attacker_clans[pc.clan_id]?
          return 3
        end

        if f.owner_clan? == clan
          if siege.in_progress? || siege.@siege_start_task
            return 3
          end
        end
      end
    end

    save_siege_clan(clan)

    if attacker_clans.size == 1
      if check_conditions
        pc.reduce_adena("FortressSiege", 250000, nil, true)
      end

      start_auto_task(true)
    end

    4
  end

  def remove_attacker(clan : L2Clan?)
    unless clan
      return
    end

    if clan.fort_id == fort.residence_id
      debug { "#{clan}'s fort is this fort." }
      return
    end

    unless FortSiegeManager.registered?(clan, fort.residence_id)
      debug { "#{clan} is not registered." }
      return
    end

    remove_siege_clan(clan.id)
  end

  private def remove_siege_clan(clan_id : Int32)
    if clan_id != 0
      sql = DELETE_FORT_SIEGECLANS_BY_CLAN_ID
      GameDB.exec(sql, fort.residence_id, clan_id)
    else
      sql = DELETE_FORT_SIEGECLANS
      GameDB.exec(sql, fort.residence_id)
    end

    load_siege_clan

    if attacker_clans.empty?
      if in_progress?
        end_siege
      else
        save_fort_siege
      end

      if task = @siege_start_task
        task.cancel
        @siege_start_task = nil
      end
    end
  rescue e
    error e
  end

  def check_auto_task
    if @siege_start_task
      return
    end

    delay = fort.siege_date.ms - Time.ms

    if delay < 0
      save_fort_siege
      clear_siege_clan
      ThreadPoolManager.execute_general(->schedule_suspicious_merchant_spawn)
    else
      load_siege_clan

      if attacker_clans.empty?
        ThreadPoolManager.schedule_general(->schedule_suspicious_merchant_spawn, delay)
      else
        if delay > 3600000
          ThreadPoolManager.execute_general(->schedule_suspicious_merchant_spawn)
          task = -> { schedule_start_siege_task(3600) }
          @siege_start_task = ThreadPoolManager.schedule_general(task, delay - 3600000)
        elsif delay > 600000
          ThreadPoolManager.execute_general(->schedule_suspicious_merchant_spawn)
          task = -> { schedule_start_siege_task(600) }
          @siege_start_task = ThreadPoolManager.schedule_general(task, delay - 600000)
        elsif delay > 300000
          task = -> { schedule_start_siege_task(300) }
          @siege_start_task = ThreadPoolManager.schedule_general(task, delay - 300000)
        elsif delay > 60000
          task = -> { schedule_start_siege_task(60) }
          @siege_start_task = ThreadPoolManager.schedule_general(task, delay - 60000)
        else
          task = -> { schedule_start_siege_task(60) }
          @siege_start_task = ThreadPoolManager.schedule_general(task, 0)
        end

        info { "Siege of #{fort.name} fort: #{fort.siege_date.time}." }
      end
    end
  end

  def start_auto_task(set_time : Bool)
    if @siege_start_task
      return
    end

    if set_time
      set_siege_date_time(false)
    end

    if owner = fort.owner_clan?
      owner.broadcast_to_online_members(SystemMessage.a_fortress_is_under_attack)
    end

    task = -> { schedule_start_siege_task(3600) }
    @siege_start_task = ThreadPoolManager.schedule_general(task, 0)
  end

  def teleport_player(who : FortTeleportWhoType, where : TeleportWhereType)
    case who
    when .owner?
      players = owners_in_zone
    when .attacker?
      players = attackers_in_zone
    else
      players = players_in_zone
    end

    players.each do |pc|
      if pc.override_fortress_conditions? || pc.jailed?
        next
      end

      pc.tele_to_location(where)
    end
  end

  private def add_attacker(clan_id : Int32)
    attacker_clans << L2SiegeClan.new(clan_id, SiegeClanType::ATTACKER)
  end

  def already_registered_for_same_day?(clan : L2Clan) : Bool
    FortSiegeManager.sieges.each do |siege|
      if siege == self
        next
      end

      if siege.siege_date.day == siege_date.day
        if siege.attacker?(clan)
          return true
        end

        if siege.defeneder?(clan)
          return true
        end
      end
    end

    false
  end

  private def set_siege_date_time(merchant : Bool)
    new_date = Calendar.new

    if merchant
      new_date.add(FortSiegeManager.suspicious_merchant_respawn_delay.minutes)
    else
      new_date.add(60.minutes)
    end

    fort.siege_date = new_date
    save_siege_date
  end

  private def load_siege_clan
    attacker_clans.clear

    sql = "SELECT clan_id FROM fortsiege_clans WHERE fort_id=?"
    GameDB.each(sql, fort.residence_id) do |rs|
      clan_id = rs.get_i32("clan_id")
      add_attacker(clan_id)
    end
  rescue e
    error e
  end

  private def remove_commanders
    @commanders.each do |sp|
      sp.stop_respawn
      if last = sp.last_spawn
        last.delete_me
      end
    end

    @commanders.clear
  end

  private def remove_flags
    attacker_clans.each &.remove_flags
  end

  private def save_fort_siege
    clear_siege_date
    save_siege_date
  end

  private def save_siege_date
    sql = "UPDATE fort SET siegeDate = ? WHERE id = ?"
    GameDB.exec(sql, siege_date.ms, fort.residence_id)
  rescue e
    error e
  end

  private def save_siege_clan(clan : L2Clan)
    if attacker_clans.size >= FortSiegeManager.attacker_max_clans
      return
    end

    sql = "INSERT INTO fortsiege_clans (clan_id,fort_id) values (?,?)"
    GameDB.exec(sql, clan.id, fort.residence_id)

    add_attacker(clan.id)
  rescue e
    error e
  end

  private def spawn_commanders
    @commanders.clear

    FortSiegeManager.get_commander_spawn_list(fort.residence_id).not_nil!.each do |sp|
      dat = L2Spawn.new(sp.id)
      dat.amount = 1
      dat.x = sp.location.x
      dat.y = sp.location.y
      dat.z = sp.location.z
      dat.heading = sp.location.heading
      dat.respawn_delay = 60
      dat.do_spawn
      dat.stop_respawn

      @commanders << dat
    end
  rescue e
    error e
  end

  private def spawn_flag(id : Int32)
    FortSiegeManager.get_flag_list(id).not_nil!.each &.spawn_me
  end

  private def unspawn_flags
    if list = FortSiegeManager.get_flag_list(fort.residence_id)
      list.each &.unspawn_me
    else
      debug "Fort #{fort.name} has no flag list."
    end
  end

  private def spawn_siege_guard
    siege_guard_manager.spawn_siege_guard
  end

  def get_attacker_clan(clan : L2Clan?) : L2SiegeClan?
    if clan
      get_attacker_clan(clan.id)
    end
  end

  def get_attacker_clan(clan_id : Int32) : L2SiegeClan?
    attacker_clans.find { |sc| sc.clan_id == clan_id }
  end

  def attacker_clans : IArray(L2SiegeClan)?
    @attacker_clans
  end

  def siege_date : Calendar
    fort.siege_date
  end

  def get_flag(clan : L2Clan?) : IArray(L2Npc)?
    if clan
      if sc = get_attacker_clan(clan)
        sc.flag
      end
    end
  end

  def siege_guard_manager
    @siege_guard_manager ||= FortSiegeGuardManager.new(fort)
  end

  def reset_siege
    remove_commanders
    spawn_commanders
    fort.reset_doors
  end

  def get_defender_clan(clan_id : Int32) : L2SiegeClan?
    # return nil
  end

  def get_defender_clan(clan : L2Clan?) : L2SiegeClan?
    # return nil
  end

  def defender_clans : IArray(L2SiegeClan)?
    # return nil
  end

  def give_fame? : Bool
    true
  end

  def fame_frequency : Int32
    Config.fortress_zone_fame_task_frequency.to_i32
  end

  def fame_amount : Int32
    Config.fortress_zone_fame_aquire_points
  end

  def update_siege
    # no-op
  end

  #

  private def schedule_end_siege_task
    unless in_progress?
      return
    end

    @siege_end = nil
    end_siege
  rescue e
    error e
  end

  private def schedule_start_siege_task(time : Int32)
    case time
    when 3600
      task = -> { schedule_start_siege_task(600) }
      ThreadPoolManager.schedule_general(task, 3_000_000)
    when 600
      fort.despawn_suspicious_merchant
      sm = SystemMessage.s1_minutes_until_the_fortress_battle_starts
      sm.add_int(10)
      announce_to_player(sm)
      task = -> { schedule_start_siege_task(300) }
      ThreadPoolManager.schedule_general(task, 300_000)
    when 300
      sm = SystemMessage.s1_minutes_until_the_fortress_battle_starts
      sm.add_int(5)
      announce_to_player(sm)
      task = -> { schedule_start_siege_task(60) }
      ThreadPoolManager.schedule_general(task, 240_000)
    when 60
      sm = SystemMessage.s1_minutes_until_the_fortress_battle_starts
      sm.add_int(1)
      announce_to_player(sm)
      task = -> { schedule_start_siege_task(30) }
      ThreadPoolManager.schedule_general(task, 30_000)
    when 30
      sm = SystemMessage.s1_seconds_until_the_fortress_battle_starts
      sm.add_int(30)
      announce_to_player(sm)
      task = -> { schedule_start_siege_task(10) }
      ThreadPoolManager.schedule_general(task, 20_000)
    when 10
      sm = SystemMessage.s1_seconds_until_the_fortress_battle_starts
      sm.add_int(10)
      announce_to_player(sm)
      task = -> { schedule_start_siege_task(5) }
      ThreadPoolManager.schedule_general(task, 5000)
    when 5
      sm = SystemMessage.s1_seconds_until_the_fortress_battle_starts
      sm.add_int(5)
      announce_to_player(sm)
      task = -> { schedule_start_siege_task(1) }
      ThreadPoolManager.schedule_general(task, 4000)
    when 1
      sm = SystemMessage.s1_seconds_until_the_fortress_battle_starts
      sm.add_int(1)
      announce_to_player(sm)
      task = -> { schedule_start_siege_task(0) }
      ThreadPoolManager.schedule_general(task, 1000)
    when 0
      @fort.siege.start_siege
    else
      warn { "#schedule_start_siege_task: Unknown siege time #{time}." }
    end
  rescue e
    error e
  end

  private def schedule_suspicious_merchant_spawn
    if in_progress?
      return
    end

    @fort.spawn_suspicious_merchant
  rescue e
    error e
  end

  private def schedule_siege_restore
    unless in_progress?
      return
    end

    @siege_restore = nil
    reset_siege
    announce_to_player(SystemMessageId::BARRACKS_FUNCTION_RESTORED)
  rescue e
    error e
  end

  def to_log(io : IO)
    super
    io << '(' << fort.name << ')'
  end
end
