module L2Event
  extend self
  include Loggable
  include Packets::Outgoing

  enum EventState : UInt8
    OFF # Not running
    STANDBY # Waiting for participants to register
    ON # Registration is over and the event has started.
  end

  TEAM_NAMES = Concurrent::Map(Int32, String).new
  TEAMS = Concurrent::Map(Int32, Concurrent::Array(L2PcInstance)).new
  private REGISTERED_PLAYERS = Concurrent::Array(L2PcInstance).new
  private CONNECTION_LOSS_DATA = Concurrent::Map(L2PcInstance, PlayerEventHolder).new
  private SPAWNS = Concurrent::Array(L2Spawn).new

  @@event_creator = ""
  @@event_info = ""

  class_getter event_state = EventState::OFF
  class_property npc_id : Int32 = 0
  class_property event_name : String = ""
  class_property teams_number : Int32 = 0

  def get_player_team_id(pc : L2PcInstance) : Int32
    TEAMS.each do |team_id, team|
      if team.includes?(pc)
        return team_id
      end
    end

    -1
  end

  def get_top_n_killers(n : Int32) : Indexable(L2PcInstance)
    tmp = {} of L2PcInstance => Int32
    TEAMS.each_value do |team_list|
      team_list.each do |pc|
        if es = pc.event_status
          tmp[pc] = es
        end
      end
    end

    sort_by_value(tmp)

    tmp.size <= n ? tmp.keys_slice : tmp.keys_slice[1...n]
  end

  def show_event_html(pc : L2PcInstance, l2id : String)
    if @@event_state.standby?
      begin
        html = NpcHtmlMessage.new(l2id.to_i)

        if REGISTERED_PLAYERS.includes?(pc)
          htm_content = HtmCache.get_htm(pc, "data/html/mods/EventEngine/Participating.htm")
        else
          htm_content = HtmCache.get_htm(pc, "data/html/mods/EventEngine/Participation.htm")
        end

        if htm_content
          html.html = htm_content
        end

        html["%objectId%"] = l2id
        html["%eventName%"] = @@event_name
        html["%eventCreator%"] = @@event_creator
        html["%eventInfo%"] = @@event_info
        pc.send_packet(html)
      rescue e
        error e
      end
    end
  end

  # Spawns an event participation NPC near the player.
  def spawn_event_npc(target : L2PcInstance)
    sp = L2Spawn.new(@@npc_id)
    sp.x = target.x + 50
    sp.y = target.y + 50
    sp.z = target.z
    sp.amount = 1
    sp.heading = target.heading
    sp.stop_respawn
    SpawnTable.add_new_spawn(sp, false)

    sp.init
    last_spawn = sp.last_spawn.not_nil!
    last_spawn.current_hp = last_spawn.max_hp.to_f
    last_spawn.title = @@event_name
    last_spawn.event_mob = true

    msu = MagicSkillUse.new(last_spawn, last_spawn, 1034, 1, 1, 1)
    last_spawn.broadcast_packet(msu)
    SPAWNS << sp
  rescue e
    error e
  end

  def unspawn_event_npcs
    SPAWNS.each do |sp|
      npc = sp.last_spawn
      if npc && npc.event_mob?
        npc.delete_me
        sp.stop_respawn
        SpawnTable.delete_spawn(sp, false)
      end
    end

    SPAWNS.clear
  end

  def participant?(pc : L2PcInstance) : Bool
    return false unless pc.event_status

    case @@event_state
    when EventState::OFF
      return false
    when EventState::STANDBY
      return REGISTERED_PLAYERS.includes?(pc)
    when EventState::ON
      TEAMS.each_value do |team_list|
        if team_list.includes?(pc)
          return true
        end
      end
    end

    false
  end

  def register_player(pc : L2PcInstance)
    unless @@event_state.standby?
      pc.send_message("The registration period for this event is over.")
      return
    end

    if Config.dualbox_check_max_l2event_participants_per_ip == 0 || AntiFeedManager.try_add_player(AntiFeedManager::L2EVENT_ID, pc, Config.dualbox_check_max_l2event_participants_per_ip)
      REGISTERED_PLAYERS << pc
    else
      pc.send_message("You have reached the maximum allowed participants per IP.")
    end
  end

  def remove_and_reset_player(pc : L2PcInstance)
    if participant?(pc)
      if pc.dead?
        pc.restore_exp(100.0)
        pc.do_revive
        pc.set_current_hp_mp(pc.max_hp.to_f, pc.max_mp.to_f)
        pc.current_cp = pc.max_cp.to_f
      end

      pc.poly.set_poly_info(nil, "1")
      pc.decay_me
      pc.spawn_me(*pc.xyz)
      info1 = CharInfo.new(pc)
      pc.broadcast_packet(info1)
      info2 = UserInfo.new(pc)
      pc.send_packet(info2)
      pc.broadcast_packet(ExBrExtraUserInfo.new(pc))

      pc.stop_transformation(true)
    end

    if es = pc.event_status
      es.restore_player_stats
      pc.event_status = nil
    end

    REGISTERED_PLAYERS.delete_first(pc)
    team_id = get_player_team_id(pc)
    TEAMS[team_id]?.try &.delete_first(pc)
  rescue e
    error e
  end

  def save_player_event_status(pc : L2PcInstance)
    CONNECTION_LOSS_DATA[pc] = pc.event_status
  end

  def restore_player_event_status(pc : L2PcInstance)
    if data = CONNECTION_LOSS_DATA[pc]?
      pc.event_status = data
      CONNECTION_LOSS_DATA.delete(pc)
    end
  end

  def start_event_participation : String
    begin
      case @@event_state
      when EventState::ON
        return "Cannot start event, it is already on."
      when EventState::STANDBY
        return "Cannot start event, it is on standby mode."
      when EventState::OFF
        @@event_state = EventState::STANDBY
      end

      AntiFeedManager.register_event(AntiFeedManager::L2EVENT_ID)
      AntiFeedManager.clear(AntiFeedManager::L2EVENT_ID)

      unspawn_event_npcs
      REGISTERED_PLAYERS.clear

      unless NpcData[@@npc_id]?
        return "Cannot start event, invalid npc id."
      end

      begin
        File.open("#{Config.datapack_root}/data/events/#{@@event_name}") do |f|
          @@event_creator = f.gets.not_nil!
          @@event_info = f.gets.not_nil!
        end
      rescue e
        error e
      end

      temp = [] of L2PcInstance
      L2World.players.each do |pc|
        unless pc.online?
          next
        end

        unless temp.includes?(pc)
          spawn_event_npc(pc)
          temp << pc
        end
        pc.known_list.each_player do |pl|
          if (pl.x - pc.x).abs < 1000 && (pl.y - pc.y).abs < 1000
            if (pl.z - pc.z).abs < 1000
              temp << pl
            end
          end
        end
      end
    rescue e
      error e
      return "Cannot start event participation, an error has occured."
    end

    "The event participation has been successfully started."
  end

  def start_event : String
    begin
      case @@event_state
      when EventState::ON
        return "Cannot start event, it is already on."
      when EventState::STANDBY
        @@event_state = EventState::ON
      when EventState::OFF # Event is off, so no problem turning it on.
        return "Cannot start event, it is off. Participation start is required."
      end

      unspawn_event_npcs
      TEAMS.clear
      CONNECTION_LOSS_DATA.clear

      @@teams_number.times do |i|
        TEAMS[i &+ 1] = Concurrent::Array(L2PcInstance).new
      end

      i = 0
      until REGISTERED_PLAYERS.empty?
        max = 0
        toplvl_pc = nil
        REGISTERED_PLAYERS.each do |pc|
          if max < pc.level
            max = pc.level
            toplvl_pc = pc
          end
        end

        next unless toplvl_pc

        REGISTERED_PLAYERS.delete_first(toplvl_pc)
        TEAMS[i &+ 1] << toplvl_pc
        toplvl_pc.set_event_status
        i = (i &+ 1) % @@teams_number
      end
    rescue e
      error e
      return "Cannot start event, an error has occured."
    end

    "The event has been successfully started."
  end

  def finish_event : String
    case @@event_state
    when EventState::OFF
      return "Cannot finish event, it is already off."
    when EventState::STANDBY
      REGISTERED_PLAYERS.safe_each do |pc|
        remove_and_reset_player(pc)
      end

      unspawn_event_npcs
      REGISTERED_PLAYERS.clear
      TEAMS.clear
      CONNECTION_LOSS_DATA.clear
      @@teams_number = 0
      @@event_name = ""
      @@event_state = EventState::OFF
      return "The event has been stopped at STANDBY mode, all players unregistered and all event npcs unspawned."
    when EventState::ON
      TEAMS.each_value do |team_list|
        team_list.safe_each do |pc|
          remove_and_reset_player(pc)
        end
      end

      @@event_state = EventState::OFF
      AntiFeedManager.clear(AntiFeedManager::TVT_ID)
      unspawn_event_npcs
      REGISTERED_PLAYERS.clear
      TEAMS.clear
      CONNECTION_LOSS_DATA.clear
      @@teams_number = 0
      @@event_name = ""
      @@npc_id = 0
      @@event_creator = ""
      @@event_info = ""
      return "The event has been stopped, all players unregistered and all event npcs unspawned."
    end

    "The event has been successfully finished."
  end

  private def sort_by_value(map : Concurrent::Map(L2PcInstance, Int32))
    list = map.to_a
    list.sort_by! { |tuple| tuple[1] }
    map.clear
    list.each { |k, v| map[k] = v }
  end
end
