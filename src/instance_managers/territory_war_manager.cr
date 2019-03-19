require "../models/territory_ward"

module TerritoryWarManager
  extend self
  extend Siegable
  extend Loggable
  include Packets::Outgoing

  private DELETE = "DELETE FROM territory_registrations WHERE castleId = ? and registeredId = ?"
  private INSERT = "INSERT INTO territory_registrations (castleId, registeredId) values (?, ?)"
  QN = "TerritoryWarSuperClass"
  GLOBAL_VARIABLE = "nextTWStartDate"
  TERRITORY_ITEM_IDS = {
    81 => 13757, 82 => 13758, 83 => 13759, 84 => 13760, 85 => 13761,
    86 => 13762, 87 => 13763, 88 => 13764, 89 => 13765
  }
  private REGISTERED_CLANS = Hash(Int32, Array(L2Clan)).new
  private REGISTERED_MERCENARIES = Hash(Int32, Array(Int32)).new
  private TERRITORY_LIST = Hash(Int32, Territory).new
  private DISGUISED_PLAYERS = Array(Int32).new
  private TERRITORY_WARDS = Array(TerritoryWard).new
  private CLAN_FLAGS = Hash(L2Clan, L2SiegeFlagInstance).new
  private PARTICIPANT_POINTS = Hash(Int32, Slice(Int32)).new
  private START_TW_DATE = Calendar.new

  @@DEFENDER_MAX_CLANS = 0
  @@DEFENDER_MAX_PLAYERS = 0
  @@CLAN_MIN_LEVEL = 0
  @@PLAYER_MIN_LEVEL = 0
  class_getter min_tw_badge_for_nobless = 0
  class_getter min_tw_badge_for_striders = 0
  class_getter min_tw_badge_for_big_strider = 0
  @@WAR_LENGTH = 0i64
  @@PLAYER_WITH_WARD_CAN_BE_KILLED_IN_PEACE_ZONE = false
  @@SPAWN_WARDS_WHEN_TW_IS_NOT_IN_PROGRESS = false
  @@RETURN_WARDS_WHEN_TW_STARTS = false

  class_getter? registration_over = true
  class_getter? tw_channel_open = false
  class_getter? tw_in_progress = false
  @@scheduled_start_tw_task : Runnable::RunnableTask?
  @@scheduled_end_tw_task : Runnable::RunnableTask?
  @@scheduled_reward_online_task : Runnable::RunnableTask?

  def load
    cfg = StatsSet.new
    cfg.parse(Dir.current + Config::TW_CONFIGURATION_FILE)

    @@DEFENDER_MAX_CLANS = cfg.get_i32("DefenderMaxClans", 500)
    @@DEFENDER_MAX_PLAYERS = cfg.get_i32("DefenderMaxPlayers", 500)
    @@CLAN_MIN_LEVEL = cfg.get_i32("ClanMinLevel", 0)
    @@PLAYER_MIN_LEVEL = cfg.get_i32("PlayerMinLevel", 40)
    @@WAR_LENGTH = cfg.get_i64("WarLength", 120) * 60000
    @@PLAYER_WITH_WARD_CAN_BE_KILLED_IN_PEACE_ZONE = cfg.get_bool("PlayerWithWardCanBeKilledInPeaceZone", false)
    @@SPAWN_WARDS_WHEN_TW_IS_NOT_IN_PROGRESS = cfg.get_bool("SpawnWardsWhenTWIsNotInProgress", false)
    @@RETURN_WARDS_WHEN_TW_STARTS = cfg.get_bool("ReturnWardsWhenTWStarts", false)
    @@min_tw_badge_for_nobless = cfg.get_i32("MinTerritoryBadgeForNobless", 100)
    @@min_tw_badge_for_striders = cfg.get_i32("MinTerritoryBadgeForStriders", 50)
    @@min_tw_badge_for_big_strider = cfg.get_i32("MinTerritoryBadgeForBigStrider", 80)

    begin
      sql = "SELECT * FROM territory_spawnlist"
      GameDB.each(sql) do |rs|
        castle_id = rs.get_i32("castleId")
        npc_id = rs.get_i32("npcId").to_u16.to_i32
        x = rs.get_i32("x")
        y = rs.get_i32("y")
        z = rs.get_i32("z")
        heading = rs.get_i32("heading")
        loc = Location.new(x, y, z, heading)
        spawn_type = rs.get_i32("spawnType")
        TERRITORY_LIST[castle_id] ||= Territory.new(castle_id)
        case spawn_type
        when 0..2
          sp = TerritoryNPCSpawn.new(castle_id, loc, npc_id, spawn_type, nil)
          TERRITORY_LIST[castle_id].spawn_list << sp
        when 3
          TERRITORY_LIST[castle_id].add_ward_spawn_place(loc)
        else
          id = rs.get_i32("id")
          warn "Unknown npc type for #{id}."
        end
      end
    rescue e
      error e
    end

    begin
      sql = "SELECT * FROM territories"
      GameDB.each(sql) do |rs|
        castle_id = rs.get_i32("castleId")
        fort_id = rs.get_i32("fortId")
        owned_ward_ids = rs.get_string("ownedWardIds")
        if t = TERRITORY_LIST[castle_id]?
          t.fort_id = fort_id
          castle = CastleManager.get_castle_by_id!(castle_id)
          if castle.owner_id > 0
            clan = ClanTable.get_clan!(castle.owner_id)
            t.owner_clan = clan
            t.change_npcs_spawn(0, true)
          end

          unless owned_ward_ids.empty?
            owned_ward_ids.split(';').each do |str_id|
              if str_id.empty?
                next
              end
              id = str_id.to_i
              if id > 0
                add_territory_ward(id, castle_id, 0, false)
              end
            end
          end
        end
      end
    rescue e
      error e
    end

    begin
      sql = "SELECT * FROM territory_registrations"
      GameDB.each(sql) do |rs|
        castle_id = rs.get_i32("castleId")
        registered_id = rs.get_i32("registeredId")
        if clan = ClanTable.get_clan(registered_id)
          REGISTERED_CLANS[castle_id] ||= [] of L2Clan
          REGISTERED_CLANS[castle_id] << clan
        else
          REGISTERED_MERCENARIES[castle_id] ||= [] of Int32
          REGISTERED_MERCENARIES[castle_id] << registered_id
        end
      end
    rescue e
      error e
    end
  end

  def get_registered_territory_id(pc : L2PcInstance) : Int32
    if !@@tw_channel_open || pc.level < @@PLAYER_MIN_LEVEL
      return 0
    end

    if clan = pc.clan?
      if clan.castle_id > 0
        return clan.castle_id + 80
      end

      REGISTERED_CLANS.each do |id, array|
        if array.includes?(clan)
          return id + 80
        end
      end
    end

    REGISTERED_MERCENARIES.each do |id, array|
      if array.includes?(pc.l2id)
        return id + 80
      end
    end

    0
  end

  def ally_field?(pc : L2PcInstance, field_id : Int32) : Bool
    temp_side = pc.siege_side - 80

    if pc.siege_side == 0
      return false
    elsif temp_side == field_id
      return true
    elsif field_id > 100 && TERRITORY_LIST.has_key?(temp_side)
      if TERRITORY_LIST[temp_side].fort_id == field_id
        return true
      end
    end

    false
  end

  def registered?(castle_id : Int32, clan : L2Clan?) : Bool
    return false unless clan

    if clan.castle_id > 0
      return castle_id == -1 ? true : clan.castle_id == castle_id
    end

    if castle_id == -1
      REGISTERED_CLANS.each do |id, array|
        if array.includes?(clan)
          return true
        end
      end

      return false
    end

    REGISTERED_CLANS[castle_id].includes?(clan)
  end

  def registered?(castle_id : Int32, l2id : Int32) : Bool
    if castle_id == -1
      REGISTERED_MERCENARIES.each do |id, array|
        if array.includes?(l2id)
          return true
        end
      end

      return false
    end

    REGISTERED_MERCENARIES[castle_id].includes?(l2id)
  end

  def get_territory(castle_id : Int32) : Territory?
    TERRITORY_LIST[castle_id]?
  end

  def get_territory!(castle_id : Int32) : Territory
    unless territory = get_territory(castle_id)
      raise "No territory for castle id #{castle_id}"
    end

    territory
  end

  def territories : Array(Territory)
    TERRITORY_LIST.local_each_value.select(&.owner_clan?).to_a
  end

  def get_registered_clans(castle_id : Int32) : Array(L2Clan)?
    REGISTERED_CLANS[castle_id]?
  end

  def get_registered_clans!(castle_id : Int32) : Array(L2Clan)
    REGISTERED_CLANS[castle_id]
  end

  def add_disguised_player(l2id : Int32)
    DISGUISED_PLAYERS << l2id
  end

  def disguised?(l2id : Int32) : Bool
    DISGUISED_PLAYERS.includes?(l2id)
  end

  def get_registered_mercenaries(castle_id : Int32) : Array(Int32)
    REGISTERED_MERCENARIES[castle_id]
  end

  def tw_start_time_in_millis : Int64
    START_TW_DATE.ms
  end

  def tw_start
    START_TW_DATE
  end

  def tw_start_time_in_millis(time : Int64)
    START_TW_DATE.ms = time

    if @@tw_in_progress
      if task = @@scheduled_end_tw_task
        task.cancel
      end

      task = ScheduleEndTWTask.new
      @@scheduled_end_tw_task = ThreadPoolManager.schedule_general(task, 1000)
    else
      if task = @@scheduled_start_tw_task
        task.cancel
      end

      task = ScheduleStartTWTask.new
      @@scheduled_start_tw_task = ThreadPoolManager.schedule_general(task, 1000)
    end
  end

  def register_clan(castle_id : Int32, clan : L2Clan)
    array = REGISTERED_CLANS[castle_id]?
    if array && array.includes?(clan)
      return
    end

    REGISTERED_CLANS[castle_id] ||= [] of L2Clan
    REGISTERED_CLANS[castle_id] << clan
    change_registration(castle_id, clan.id, false)
  end

  def register_merc(castle_id : Int32, pc : L2PcInstance)
    array = REGISTERED_MERCENARIES[castle_id]?
    if pc.level < @@PLAYER_MIN_LEVEL || (array && array.includes?(pc.l2id))
      return
    end

    REGISTERED_MERCENARIES[castle_id] ||= [] of Int32
    REGISTERED_MERCENARIES[castle_id] << pc.l2id
    change_registration(castle_id, pc.l2id, false)
  end

  def remove_clan(castle_id : Int32, clan : L2Clan)
    if array = REGISTERED_CLANS[castle_id]?
      if idx = array.index(clan)
        REGISTERED_CLANS.delete_at(idx)
        change_registration(castle_id, clan.id, true)
      end
    end
  end

  def remove_merc(castle_id : Int32, pc : L2PcInstance)
    if array = REGISTERED_MERCENARIES[castle_id]?
      if idx = array.index(pc.l2id)
        REGISTERED_MERCENARIES.delete_at(idx)
        change_registration(castle_id, pc.l2id, true)
      end
    end
  end

  def territory_catapult_destroyed(castle_id : Int32)
    if temp = TERRITORY_LIST[castle_id]?
      temp.change_npcs_spawn(2, false)
    end

    CastleManager.get_castle_by_id!(castle_id).doors.each do |door|
      door.open_me
    end
  end

  def add_territory_ward(territory_id : Int32, new_owner_id : Int32, old_owner_id : Int32, broadcast_msg : Bool) : L2Npc?
    ret = nil

    if ter_new = TERRITORY_LIST[new_owner_id]?
      if ward = ter_new.free_ward_spawn_place
        ward.npc_id = territory_id
        ret = spawn_npc(36491 + territory_id, ward.location)
        ward.npc = ret
        if !tw_in_progress? && !@@SPAWN_WARDS_WHEN_TW_IS_NOT_IN_PROGRESS
          ret.decay_me
        end

        if ter_new.owner_clan? && ter_new.owned_ward_ids.includes?(new_owner_id + 80)
          ter_new.owned_ward_ids.each do |ward_id|
            SkillTreesData.get_available_residential_skills(ward_id).each do |s|
              if sk = SkillData[s.skill_id, s.skill_level]?
                ter_new.owner_clan.each_online_player do |m|
                  unless m.in_olympiad_mode?
                    m.add_skill(sk, false)
                  end
                end
              end
            end
          end
        end
      end

      if ter_old = TERRITORY_LIST[old_owner_id]?
        ter_old.remove_ward(territory_id)
        update_territory_data(ter_old)
        update_territory_data(ter_new)
        if broadcast_msg
          sm = SystemMessage.clan_s1_has_succeded_in_capturing_s2_territory_ward
          sm.add_string(ter_new.owner_clan.name)
          sm.add_castle_id(territory_id)
          announce_to_participants(sm, 135000, 13500)
        end

        if ter_old.owner_clan?
          SkillTreesData.get_available_residential_skills(territory_id).each do |s|
            if sk = SkillData[s.skill_id, s.skill_level]?
              ter_old.owner_clan.each_online_player do |m|
                m.remove_skill(sk, false)
              end
            end
          end

          unless ter_old.owned_ward_ids.empty?
            unless ter_old.owned_ward_ids.includes?(old_owner_id + 80)
              ter_old.owned_ward_ids.each do |ward_id|
                SkillTreesData.get_available_residential_skills(ward_id).each do |s|
                  if sk = SkillData[s.skill_id, s.skill_level]?
                    ter_old.owner_clan.each_online_player do |m|
                      m.remove_skill(sk, false)
                    end
                  end
                end
              end
            end
          end
        end
      end
    else
      warn "Missing territory for new ward owner: #{new_owner_id}; #{territory_id}."
    end

    ret
  end

  def get_hq_for_clan(clan : L2Clan) : L2SiegeFlagInstance?
    if clan.castle_id > 0
      TERRITORY_LIST[clan.castle_id].hq
    end
  end

  def get_hq_for_territory(territory_id : Int32) : L2SiegeFlagInstance?
    TERRITORY_LIST[territory_id - 80].hq
  end

  def set_hq_for_clan(clan : L2Clan, hq : L2SiegeFlagInstance?)
    if clan.castle_id > 0
      TERRITORY_LIST[clan.castle_id].hq = hq
    end
  end

  def add_clan_flag(clan : L2Clan, flag : L2SiegeFlagInstance)
    CLAN_FLAGS[clan] = flag
  end

  def clan_has_flag?(clan : L2Clan) : Bool
    CLAN_FLAGS.has_key?(clan)
  end

  def get_flag_for_clan(clan : L2Clan) : L2SiegeFlagInstance?
    CLAN_FLAGS[clan]?
  end

  def remove_clan_flag(clan : L2Clan)
    CLAN_FLAGS.delete(clan)
  end

  def territory_wards
    TERRITORY_WARDS
  end

  def get_territory_ward_for_owner(castle_id : Int32) : TerritoryWard?
    TERRITORY_WARDS.find { |ward| ward.territory_id == castle_id }
  end

  def get_territory_ward(territory_id) : TerritoryWard?
    TERRITORY_WARDS.find { |ward| ward.territory_id == territory_id }
  end

  def get_territory_ward(pc : L2PcInstance)
    TERRITORY_WARDS.find { |ward| ward.player_id == pc.l2id }
  end

  def get_territory_ward!(*args) : TerritoryWard
    unless ward = get_territory_ward(*args)
      raise "No TerritoryWard found with args #{args}"
    end

    ward
  end

  def drop_combat_flag(pc : L2PcInstance, killed : Bool, spawn_back : Bool)
    TERRITORY_WARDS.each do |ward|
      if ward.player_id == pc.l2id
        ward.drop_it

        if tw_in_progress?
          if killed
            ward.spawn_me
          elsif spawn_back
            ward.spawn_back
          else
            TERRITORY_LIST[ward.owner_castle_id].owned_ward.each_with_index do |ward_spawn, i|
              unless ward_spawn
                raise "Ward at index #{i} is nil"
              end
              if ward_spawn.id == ward.territory_id
                ward_spawn.npc = ward_spawn.npc.spawn.do_spawn
                ward.unspawn_me
                ward.npc = ward_spawn.npc
              end
            end
          end
        end

        if killed
          sm = SystemMessage.the_char_that_acquired_s1_ward_has_been_killed
          sm.add_string(ward.npc.name.gsub(" Ward", ""))
          announce_to_participants(sm, 0, 0)
        end
      end
    end
  end

  def give_tw_quest_point(pc : L2PcInstance)
    PARTICIPANT_POINTS[pc.l2id] ||= Int32.slice(
      pc.siege_side,
      0,
      0,
      0,
      0,
      0,
      0
    )
    PARTICIPANT_POINTS[pc.l2id][2] += 1
  end

  def give_tw_point(killer : L2PcInstance, victim_side : Int32, type : Int32)
    if victim_side == 0
      return
    end

    if killer.party? && type < 5
      killer.party.members.each do |pc|
        if pc.siege_side == victim_side || pc.siege_side == 0 || !Util.in_range?(2000, killer, pc, false)
          next
        end
        PARTICIPANT_POINTS[pc.l2id] ||= Int32.slice(
          pc.siege_side,
          0,
          0,
          0,
          0,
          0,
          0
        )
        PARTICIPANT_POINTS[pc.l2id][type] += 1
      end
    else
      if killer.siege_side == victim_side || killer.siege_side == 0
        return
      end

      PARTICIPANT_POINTS[killer.l2id] ||= Int32.slice(
        killer.siege_side,
        0,
        0,
        0,
        0,
        0,
        0
      )
      PARTICIPANT_POINTS[killer.l2id][type] += 1
    end
  end

  def calc_reward(pc : L2PcInstance) : Slice(Int32)
    reward = Slice.new(2, 0)

    if temp = PARTICIPANT_POINTS[pc.l2id]?
      reward[0] = temp[0]
      if temp[6] < 10
        return reward
      end

      reward[1] += (temp[6] > 70 ? 7 : (temp[6] * 0.1).to_i)
      reward[1] += temp[2] * 7

      if temp[1] < 50
        reward[1] += (temp[1] * 0.1).to_i
      elsif temp[1] < 120
        reward[1] += 5 + ((temp[1] - 50) / 14)
      else
        reward[1] += 10
      end

      reward[1] += temp[3]
      reward[1] += temp[4] * 2
      reward[1] += temp[5] > 0 ? 5 : 0

      reward[1] += Math.min(TERRITORY_LIST[temp[0] - 80].quest_done[0], 10)
      reward[1] += TERRITORY_LIST[temp[0] - 80].quest_done[1]
      reward[1] += TERRITORY_LIST[temp[0] - 80].owned_ward_ids.size
      return reward
    end

    reward
  end

  def debug_reward(pc)
    # TODO
  end

  def reset_reward(pc : L2PcInstance)
    if temp = PARTICIPANT_POINTS[pc.l2id]?
      temp[6] = 0
    end
  end

  def spawn_npc(npc_id : Int32, loc : Location) : L2Npc
    sp = L2Spawn.new(npc_id)
    sp.amount = 1
    sp.x = loc.x
    sp.y = loc.y
    sp.z = loc.z
    sp.heading = loc.heading
    sp.stop_respawn
    sp.spawn_one(false)
  end

  private def change_registration(castle_id : Int32, l2id : Int32, delete : Bool)
    sql = delete ? DELETE : INSERT
    GameDB.exec(sql, castle_id, l2id)
  rescue e
    error e
  end

  private def update_territory_data(ter : Territory)
    ward_list = String.build do |io|
      ter.owned_ward_ids.each { |i| io << i << ';' }
    end

    sql = "UPDATE territories SET ownedWardIds=? WHERE territoryId=?"
    GameDB.exec(sql, ward_list, ter.territory_id)
  rescue e
    error e
  end

  private def start_territory_war
    active_territory_list = [] of Territory
    TERRITORY_LIST.each_value do |t|
      if castle = CastleManager.get_castle_by_id(t.castle_id)
        if castle.owner_id > 0
          active_territory_list << t
        end
      else
        warn "Castle with id #{t.castle_id} is missing from CastleManager."
      end
    end

    if active_territory_list < 2
      return
    end

    @@tw_in_progress = true
    unless update_player_tw_state_flags(false)
      return
    end

    active_territory_list.each do |t|
      castle = CastleManager.get_castle_by_id(t.castle_id)
      fort = FortManager.get_fort_by_id(t.fort_id)

      if castle
        t.change_npcs_spawn(2, true)
        castle.spawn_door
        castle.zone.siege_instance = self
        castle.zone.active = true
        castle.zone.update_zone_status_for_characters_inside
      else
        "Castle with id #{t.castle_id} is missing from CastleManager."
      end

      if fort
        t.change_npc_spawn(1, true)
        fort.reset_doors
        fort.zone.siege_instance = self
        fort.zone.active = true
        fort.zone.update_zone_status_for_characters_inside
      else
        "Fort with id #{t.fort_id} is missing from CastleManager."
      end

      t.owned_ward.each do |ward|
        if ward.npc? && t.owner_clan?
          unless ward.npc.visible?
            ward.npc = ward.npc.spawn.do_spawn
          end
          tw = TerritoryWard.new(ward.id, *ward.location.xyz, 0, ward.id + 13479, t.castle_id, ward.npc)
          TERRITORY_WARDS << tw
        end
      end

      t.quest_done[0] = 0 # killed npc
      t.quest_done[1] = 0 # captured wards
    end

    PARTICIPANT_POINTS.clear

    if @@RETURN_WARDS_WHEN_TW_STARTS
      TERRITORY_WARDS.each do |ward|
        if ward.owner_castle_id != ward.territory_id - 80
          ward.unspawn_me
          ward.npc = add_territory_ward(ward.territory_id, ward.territory_id - 80, ward.owner_castle_id, false)
        end
      end
    end

    Broadcast.to_all_online_players(SystemMessageId::TERRITORY_WAR_HAS_BEGUN)
  end

  private def end_territory_war
    @@tw_in_progress = false

    active_territory_list = [] of Territory

    TERRITORY_LIST.each_value do |t|
      if castle = CastleManager.get_castle_by_id(t.castle_id)
        if castle.owner_id > 0
          active_territory_list << t
        end
      else
        warn "Castle with id #{t.castle_id} is missing from CastleManager."
      end
    end

    if active_territory_list.size < 2
      return
    end

    unless update_player_tw_state_flags(true)
      return
    end

    TERRITORY_WARDS.each &.unspawn_me
    TERRITORY_WARDS.clear

    active_territory_list.each do |t|
      castle = CastleManager.get_castle_by_id(t.castle_id)
      fort = FortManager.get_fort_by_id(t.fort_id)

      if castle
        castle.spawn_door
        t.change_npcs_spawn(2, false)
        castle.zone.active = true
        castle.zone.update_zone_status_for_characters_inside
        castle.zone.siege_instance = nil
      else
        "Castle with id #{t.castle_id} is missing from CastleManager."
      end

      if fort
        t.change_npc_spawn(1, false)
        fort.zone.active = true
        fort.zone.update_zone_status_for_characters_inside
        fort.zone.siege_instance = nil
      else
        "Fort with id #{t.fort_id} is missing from CastleManager."
      end

      if hq = t.hq?
        hq.delete_me
      end

      t.owned_ward.each do |ward|
        if ward.npc? && t.owner_clan?
          if !ward.npc.visible? && @@SPAWN_WARDS_WHEN_TW_IS_NOT_IN_PROGRESS
            ward.npc = ward.npc.spawn.do_spawn
          elsif ward.npc.visible? && !@@SPAWN_WARDS_WHEN_TW_IS_NOT_IN_PROGRESS
            ward.npc.decay_me
          end
        end
      end
    end

    CLAN_FLAGS.each_value do |flag|
      flag.delete_me
    end
    CLAN_FLAGS.clear

    REGISTERED_CLANS.each do |castle_id, array|
      array.each do |clan|
        change_registration(castle_id, clan.id, true)
      end
    end

    REGISTERED_MERCENARIES.each do |castle_id, array|
      array.each do |l2id|
        change_registration(castle_id, l2id, true)
      end
    end

    Broadcast.to_all_online_players(SystemMessageId::TERRITORY_WAR_HAS_ENDED)
  end

  private def update_player_tw_state_flags(clear : Bool) : Bool
    unless tw_quest = QuestManager.get_quest(QN)
      warn "Missing main quest."
      return false
    end

    REGISTERED_CLANS.each do |castle_id, array|
      array.each do |clan|
        clan.each_online_player do |pc|
          if clear
            pc.siege_state = 0
            unless @@tw_channel_open
              pc.siege_state = 0
            end
          else
            if pc.level < @@PLAYER_MIN_LEVEL || pc.class_id.level < 2
              next
            end

            if @@tw_in_progress
              pc.siege_state = 1
            end

            pc.siege_side = castle_id + 80
          end

          pc.broadcast_user_info
        end
      end
    end

    REGISTERED_MERCENARIES.each do |castle_id, array|
      array.each do |l2id|
        unless pc = L2World.get_player(l2id)
          next
        end

        if clear
          pc.siege_state = 0
          unless @@tw_channel_open
            pc.siege_side = 0
          end
        else
          if @@tw_in_progress
            pc.siege_state = 1
          end

          pc.siege_side = castle_id + 80
        end

        pc.broadcast_user_info
      end
    end

    TERRITORY_LIST.each_value do |terr|
      if clan = ter.owner_clan?
        clan.each_online_player do |pc|
          if clear
            pc.siege_state = 0
            unless @@tw_channel_open
              pc.siege_side = 0
            end
          else
            if pc.level < @@PLAYER_MIN_LEVEL || pc.class_id.level < 2
              next
            end

            if @@tw_in_progress
              pc.siege_state = 1
            end

            pc.siege_side = terr.castle_id + 80
          end

          pc.broadcast_user_info
        end
      end
    end

    tw_quest.on_enter_world = @@tw_in_progress
    true
  end

  private def reward_online_participants
    if @@tw_in_progress
      L2World.players.each do |pc|
        if pc.siege_side > 0
          give_tw_point(pc, 1000, 6)
        end
      end
    else
      @@scheduled_reward_online_task.not_nil!.cancel
    end
  end

  private def schedule_start_tw_task # Replaces a L2J runnable class
    @@schedule_start_tw_task.not_nil!.cancel

    time = START_TW_DATE.ms - Time.ms
    if time > 7200000
      @@registration_over = false
      @@scheduled_start_tw_task = ThreadPoolManager.schedule_general(->schedule_start_tw_task, time - 7200000)
    elsif time <= 7200000 && time > 1200000
      sm = SystemMessageId::THE_TERRITORY_WAR_REGISTERING_PERIOD_ENDED
      Broadcast.to_all_online_players(sm)
      @@registration_over = true
      @@scheduled_start_tw_task = ThreadPoolManager.schedule_general(->schedule_start_tw_task, time - 1200000) # Prepare task for 20 mins left before TW start.
    elsif time <= 1200000 && time > 600000
      sm = SystemMessageId::TERRITORY_WAR_BEGINS_IN_20_MINUTES
      Broadcast.to_all_online_players(sm)
      @@tw_channel_open = true
      @@registration_over = true
      update_player_tw_state_flags(false)
      @@scheduled_start_tw_task = ThreadPoolManager.schedule_general(->schedule_start_tw_task, time - 600000) # Prepare task for 10 mins left before TW start.
    elsif time <= 600000 && time > 300000
      sm = SystemMessageId::TERRITORY_WAR_BEGINS_IN_10_MINUTES
      Broadcast.to_all_online_players(sm)
      @@tw_channel_open = true
      @@registration_over = true
      update_player_tw_state_flags(false)
      @@scheduled_start_tw_task = ThreadPoolManager.schedule_general(->schedule_start_tw_task, time - 300000) # Prepare task for 5 mins left before TW start.
    elsif time <= 300000 && time > 60000
      sm = SystemMessageId::TERRITORY_WAR_BEGINS_IN_5_MINUTES
      Broadcast.to_all_online_players(sm)
      @@tw_channel_open = true
      @@registration_over = true
      update_player_tw_state_flags(false)
      @@scheduled_start_tw_task = ThreadPoolManager.schedule_general(->schedule_start_tw_task, time - 60000) # Prepare task for 1 min left before TW start.
    elsif time <= 60000 && time > 0
      sm = SystemMessageId::TERRITORY_WAR_BEGINS_IN_1_MINUTE
      Broadcast.to_all_online_players(sm)
      @@tw_channel_open = true
      @@registration_over = true
      update_player_tw_state_flags(false)
      @@scheduled_start_tw_task = ThreadPoolManager.schedule_general(->schedule_start_tw_task, time) # Prepare task for TW start.
    elsif time + WARLENGTH > 0
      @@tw_channel_open = true
      @@registration_over = true
      start_territory_war
      @@scheduled_end_tw_task = ThreadPoolManager.schedule_general(->schedule_end_tw_task, 1000) # Prepare task for TW end.
      @@scheduled_reward_online_task = ThreadPoolManager.schedule_general(->reward_online_participants, 60000, 60000)
    end
  rescue e
    error e
  end

  private def schedule_end_tw_task # Replaces a L2J runnable class
    @@scheduled_end_tw_task.not_nil!.cancel(false)
    time = (@@START_TW_DATE.ms + WARLENGTH) - Time.ms
    if time > 3600000
      sm = SystemMessageId::THE_TERRITORY_WAR_WILL_END_IN_S1_HOURS
      sm.add_int(2)
      announce_to_participants(sm, 0, 0)
      @@scheduled_end_tw_task = ThreadPoolManager.schedule_general(->schedule_end_tw_task, time - 3600000) # Prepare task for 1 hr left.
    elsif time <= 3600000 && time > 600000
      sm = SystemMessageId::THE_TERRITORY_WAR_WILL_END_IN_S1_MINUTES
      sm.add_int((time / 60000).to_i)
      announce_to_participants(sm, 0, 0)
      @@scheduled_end_tw_task = ThreadPoolManager.schedule_general(->schedule_end_tw_task, time - 600000) # Prepare task for 10 minute left.
    elsif time <= 600000 && time > 300000
      sm = SystemMessageId::THE_TERRITORY_WAR_WILL_END_IN_S1_MINUTES
      sm.add_int((time / 60000).to_i)
      announce_to_participants(sm, 0, 0)
      @@scheduled_end_tw_task = ThreadPoolManager.schedule_general(->schedule_end_tw_task, time - 300000) # Prepare task for 5 minute left.
    elsif time <= 300000 && time > 10000
      sm = SystemMessageId::THE_TERRITORY_WAR_WILL_END_IN_S1_MINUTES
      sm.add_int((time / 60000).to_i)
      announce_to_participants(sm, 0, 0)
      @@scheduled_end_tw_task = ThreadPoolManager.schedule_general(->schedule_end_tw_task, time - 10000) # Prepare task for 10 seconds count down
    elsif time <= 10000 && time > 0
      sm = SystemMessageId::S1_SECONDS_TO_THE_END_OF_TERRITORY_WAR
      sm.add_int((time / 1000).to_i)
      announce_to_participants(sm, 0, 0)
      @@scheduled_end_tw_task = ThreadPoolManager.schedule_general(->schedule_end_tw_task, time) # Prepare task for second count down
    else
      end_territory_war
      # commented out in L2J _scheduledStartTWTask = ThreadPoolManager.schedule_general(new ScheduleStartTWTask(), 1000)
      ThreadPoolManager.schedule_general(->close_territory_channel_task, 600000)
    end
  rescue e
    error e
  end

  private def close_territory_channel_task # Replaces a L2J runnable class
    @@tw_channel_open = false
    DISGUISED_PLAYERS.clear
    update_player_tw_state_flags(true)
  end

  def announce_to_participants(sm, exp : Int32, sp : Int32)
    exp = exp.to_i64
    TERRITORY_LIST.each_value do |ter|
      ter.owner_clan?.try &.each_online_player do |m|
        m.send_packet(sm)
        if exp > 0 || sp > 0
          m.add_exp_and_sp(exp, sp)
        end
      end
    end

    REGISTERED_CLANS.each_value do |list|
      list.each do |clan|
        clan.each_online_player do |m|
          m.send_packet(sm)
          if exp > 0 || sp > 0
            m.add_exp_and_sp(exp, sp)
          end
        end
      end
    end

    REGISTERED_MERCENARIES.each_value do |list|
      list.each do |l2id|
        if pc = L2World.get_player(l2id)
          if clan = pc.clan?
            if registered?(-1, clan) # not sure about the conditional
              pc.send_packet(sm)
              if exp > 0 || sp > 0
                pc.add_exp_and_sp(exp, sp)
              end
            end
          end
        end
      end
    end
  end

  class TerritoryNPCSpawn
    # include Identifiable

    getter castle_id, location, territory_id, castle_id, quest_done, type
    getter! npc : L2Npc?
    setter npc_id : Int32
    property! owner_clan : L2Clan?
    property? in_progress : Bool = false

    initializer castle_id: Int32, location: Location, npc_id: Int32,
      type: Int32, npc: L2Npc?

    def id
      @npc_id
    end

    def npc=(npc : L2Npc?)
      @npc.try &.delete_me
      @npc = npc
    end
  end

  class Territory
    include Loggable

    @territory_ward_spawn_places = Slice(TerritoryNPCSpawn?).new(9, nil.as(TerritoryNPCSpawn?))
    @quest_done = Slice(Int32).new(2)
    getter territory_id : Int32
    getter spawn_list = [] of TerritoryNPCSpawn
    property fort_id : Int32 = 0
    property castle_id : Int32
    property? in_progress : Bool = false
    property! owner_clan : L2Clan?
    property! hq : L2SiegeFlagInstance?

    def initialize(@castle_id : Int32)
      @territory_id = castle_id + 80
    end

    def add_ward_spawn_place(loc : Location)
      @territory_ward_spawn_places.map! do |temp|
        temp || TerritoryNPCSpawn.new(@castle_id, loc, 0, 4, nil)
      end
    end

    protected def free_ward_spawn_place : TerritoryNPCSpawn?
      @territory_ward_spawn_places.each do |place|
        if place && place.npc?.nil?
          return place
        end
      end

      warn "No free ward spawn found for territory #{@territory_id}."

      @territory_ward_spawn_places.each_with_index do |temp, i|
        if temp.nil?
          warn "Territory ward spawn place #{i} is nil."
        elsif temp.npc?
          warn "Territory ward spawn place #{i} has npc name: #{temp.npc.name}."
        else
          warn "Territory ward spawn place #{i} is empty."
        end
      end

      nil
    end

    protected def change_npcs_spawn(type : Int32, is_spawn : Bool)
      if type < 0 || type > 3
        warn "Wrong type #{type} for NPCs spawn change."
        return
      end

      @spawn_list.each do |tw_spawn|
        if tw_spawn.type != type
          next
        end

        if is_spawn
          tw_spawn.npc = TerritoryWarManager.spawn_npc(tw_spawn.id, tw_spawn.location)
        else
          if npc = tw_spawn.npc?
            if npc.alive?
              npc.delete_me
            end
          end
          tw_spawn.npc = nil
        end
      end
    end

    protected def remove_ward(ward_id : Int32)
      @territory_ward_spawn_places.each_with_index do |ward_spawn, i|
        if ward_spawn
          if ward_spawn.id == ward_id
            ward_spawn.npc.delete_me
            ward_spawn.npc = nil
            ward_spawn.npc_id = 0
          end
        else
          warn "Expected ward at #{i} to not be nil."
        end
      end
    end

    def owned_ward
      @territory_ward_spawn_places
    end

    def owned_ward_ids : Array(Int32)
      ret = [] of Int32
      @territory_ward_spawn_places.each do |temp|
        if temp
          if temp.id > 0
            ret << temp.id
          end
        end
      end
      ret
    end
  end

  def player_with_ward_can_be_killed_in_peace_zone?
    @@PLAYER_WITH_WARD_CAN_BE_KILLED_IN_PEACE_ZONE
  end

  def start_siege
    raise "not supported"
  end

  def end_siege
    raise "not supported"
  end

  def get_attacker_clan?(clan_id : Int32)
    raise "not supported"
  end

  def get_attacker_clan?(clan : L2Clan?)
    raise "not supported"
  end

  def attacker_clans?
    raise "not supported"
  end

  def attackers_in_zone
    raise "not supported"
  end

  def attacker?(clan : L2Clan?)
    raise "not supported"
  end

  def get_defender_clan?(clan_id : Int32)
    raise "not supported"
  end

  def get_defender_clan?(clan : L2Clan?)
    raise "not supported"
  end

  def defender_clans?
    raise "not supported"
  end

  def defender?(clan : L2Clan?)
    raise "not supported"
  end

  def get_flag?(clan : L2Clan?)
    raise "not supported"
  end

  def siege_date
    raise "not supported"
  end

  def give_fame?
    true
  end

  def fame_frequency
    Config.castle_zone_fame_task_frequency
  end

  def fame_amount
    Config.castle_zone_fame_aquire_points
  end

  def update_siege
    # no-op
  end
end
