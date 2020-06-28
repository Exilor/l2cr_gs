require "./tasks/four_sepulchers_change_attack_time_task"
require "./tasks/four_sepulchers_change_cool_down_time_task"
require "./tasks/four_sepulchers_change_entry_time_task"
require "./tasks/four_sepulchers_change_warm_up_time_task"

module FourSepulchersManager
  extend self
  extend Synchronizable
  extend Loggable
  include Packets::Outgoing

  private QUEST_ID       = 620
  private ENTRANCE_PASS  = 7075
  private USED_PASS      = 7261
  private CHAPEL_KEY     = 7260
  private ANTIQUE_BROOCH = 7262

  private START_HALL_SPAWN = {
    Int32.slice(181632, -85587, -7218),
    Int32.slice(179963, -88978, -7218),
    Int32.slice(173217, -86132, -7218),
    Int32.slice(175608, -82296, -7218)
  }

  private SHADOW_SPAWN_LOC = {
    {
      Int32.slice(25339, 191231, -85574, -7216, 33380),
      Int32.slice(25349, 189534, -88969, -7216, 32768),
      Int32.slice(25346, 173195, -76560, -7215, 49277),
      Int32.slice(25342, 175591, -72744, -7215, 49317)
    },
    {
      Int32.slice(25342, 191231, -85574, -7216, 33380),
      Int32.slice(25339, 189534, -88969, -7216, 32768),
      Int32.slice(25349, 173195, -76560, -7215, 49277),
      Int32.slice(25346, 175591, -72744, -7215, 49317)
    },
    {
      Int32.slice(25346, 191231, -85574, -7216, 33380),
      Int32.slice(25342, 189534, -88969, -7216, 32768),
      Int32.slice(25339, 173195, -76560, -7215, 49277),
      Int32.slice(25349, 175591, -72744, -7215, 49317)
    },
    {
      Int32.slice(25349, 191231, -85574, -7216, 33380),
      Int32.slice(25346, 189534, -88969, -7216, 32768),
      Int32.slice(25342, 173195, -76560, -7215, 49277),
      Int32.slice(25339, 175591, -72744, -7215, 49317)
    }
  }

  private ARCHON_SPAWNED        = Concurrent::Map(Int32, Bool).new
  private HALL_IN_USE           = Concurrent::Map(Int32, Bool).new
  private CHALLENGERS           = Concurrent::Map(Int32, L2PcInstance).new
  private START_HALL_SPAWNS     = {} of Int32 => Slice(Int32)
  private HALL_GATEKEEPERS      = {} of Int32 => Int32
  private KEY_BOX_NPC           = {} of Int32 => Int32
  private VICTIM                = {} of Int32 => Int32
  private EXECUTIONER_SPAWNS    = {} of Int32 => L2Spawn
  private KEY_BOX_SPAWNS        = {} of Int32 => L2Spawn
  private MYSTERIOUS_BOX_SPAWNS = {} of Int32 => L2Spawn
  private SHADOW_SPAWNS         = {} of Int32 => L2Spawn
  private DUKE_FINAL_MOBS       = {} of Int32 => Array(L2Spawn)
  private DUKE_MOBS             = {} of Int32 => Array(L2SepulcherMonsterInstance)
  private EMPERORS_GRAVE_NPCS   = {} of Int32 => Array(L2Spawn)
  private MAGICAL_MONSTERS      = {} of Int32 => Array(L2Spawn)
  private PHYSICAL_MONSTERS     = {} of Int32 => Array(L2Spawn)
  private VISCOUNT_MOBS         = {} of Int32 => Array(L2SepulcherMonsterInstance)

  private PHYSICAL_SPAWNS       = [] of L2Spawn
  private MAGICAL_SPAWNS        = [] of L2Spawn
  private MANAGERS              = Concurrent::Array(L2Spawn).new
  private DUKE_FINAL_SPAWNS     = [] of L2Spawn
  private EMPERORS_GRAVE_SPAWNS = [] of L2Spawn
  private ALL_MOBS              = Concurrent::Array(L2Npc).new

  class_getter cycle_min = 55i8

  class_property change_cool_down_time_task : TaskScheduler::DelayedTask?
  class_property change_entry_time_task     : TaskScheduler::DelayedTask?
  class_property change_warm_up_time_task   : TaskScheduler::DelayedTask?
  class_property change_attack_time_task    : TaskScheduler::DelayedTask?

  class_property attack_time_end    : Int64 = 0i64
  class_property cool_down_time_end : Int64 = 0i64
  class_property entry_time_end     : Int64 = 0i64
  class_property warm_up_time_end   : Int64 = 0i64

  class_property? first_time_run : Bool = false
  class_property? entry_time     : Bool = false
  class_property? warm_up_time   : Bool = false
  class_property? attack_time    : Bool = false
  class_property? cool_down_time : Bool = false

  def init
    @@change_cool_down_time_task.try &.cancel
    @@change_entry_time_task.try &.cancel
    @@change_warm_up_time_task.try &.cancel
    @@change_attack_time_task.try &.cancel
    @@change_cool_down_time_task
    @@change_entry_time_task = nil
    @@change_warm_up_time_task = nil
    @@change_attack_time_task = nil
    @@first_time_run = true
    @@entry_time = false
    @@warm_up_time = false
    @@attack_time = false
    @@cool_down_time = false

    init_fixed_info
    load_mysterious_box
    init_key_box_spawns
    load_physical_monsters
    load_magical_monsters
    init_location_shadow_spawns
    init_executioner_spawns
    load_duke_monsters
    load_emperors_grave_monsters
    spawn_managers
    time_selector
  end

  private def time_selector
    time_calculator

    time = Time.ms

    if time >= @@cool_down_time_end && time < @@entry_time_end
      clean
      @@change_entry_time_task = ThreadPoolManager.schedule_general(FourSepulchersChangeEntryTimeTask.new, 0)
      info "Beginning in Entry time."
    elsif time >= @@entry_time_end && time < @@warm_up_time_end
      clean
      @@change_warm_up_time_task = ThreadPoolManager.schedule_general(FourSepulchersChangeWarmUpTimeTask.new, 0)
      info "Beginning in WarmUp time."
    elsif time >= @@warm_up_time_end && time < @@attack_time_end
      clean
      @@change_attack_time_task = ThreadPoolManager.schedule_general(FourSepulchersChangeAttackTimeTask.new, 0)
      info "Beginning in Attack time."
    else
      @@change_cool_down_time_task = ThreadPoolManager.schedule_general(FourSepulchersChangeCoolDownTimeTask.new, 0)
      info "Beginning in Cooldown time."
    end
  end

  private def time_calculator
    tmp = Calendar.new
    if tmp.minute < @@cycle_min
      tmp.hour &-= 1
    end
    tmp.minute = @@cycle_min

    @@cool_down_time_end = tmp.ms
    @@entry_time_end = @@cool_down_time_end + (Config.fs_time_entry * 60_000)
    @@warm_up_time_end = @@entry_time_end + (Config.fs_time_warmup * 60_000)
    @@attack_time_end = @@warm_up_time_end + (Config.fs_time_attack * 60_000)
  end

  def clean
    (31921...31925).each do |i|
      unless loc = START_HALL_SPAWNS[i]?
        warn { "#{i} is not inside START_HALL_SPAWNS (#{START_HALL_SPAWNS})." }
        next
      end

      GrandBossManager.get_zone(loc[0], loc[1], loc[2]).not_nil!.oust_all_players
    end

    delete_all_mobs

    close_all_doors

    HALL_IN_USE.clear
    (31921..31924).each { |n| HALL_IN_USE[n] = false }

    ARCHON_SPAWNED.transform_values! { |_| false }
  end

  private def spawn_managers
    MANAGERS.clear

    31921.upto(31924) do |npc_id|
      begin
        sp = L2Spawn.new(npc_id)
        sp.amount = 1
        sp.respawn_delay = 60
        case npc_id
        when 31921 # Conquerors
          sp.x = 181061
          sp.y = -85595
          sp.z = -7200
          sp.heading = -32584
        when 31922 # Emperors
          sp.x = 179292
          sp.y = -88981
          sp.z = -7200
          sp.heading = -33272
        when 31923 # Sages
          sp.x = 173202
          sp.y = -87004
          sp.z = -7200
          sp.heading = -16248
        when 31924 # Judges
          sp.x = 175606
          sp.y = -82853
          sp.z = -7200
          sp.heading = -16248
        end

        MANAGERS << sp
        SpawnTable.add_new_spawn(sp, false)
        sp.do_spawn
        sp.start_respawn
        info { "Spawned #{sp.template.name}." }
      rescue e
        error "Error while spawning managers:"
        error e
      end
    end
  end

  private def init_fixed_info
    START_HALL_SPAWNS[31921] = START_HALL_SPAWN[0]
    START_HALL_SPAWNS[31922] = START_HALL_SPAWN[1]
    START_HALL_SPAWNS[31923] = START_HALL_SPAWN[2]
    START_HALL_SPAWNS[31924] = START_HALL_SPAWN[3]

    HALL_IN_USE[31921] = false
    HALL_IN_USE[31922] = false
    HALL_IN_USE[31923] = false
    HALL_IN_USE[31924] = false

    HALL_GATEKEEPERS[31925] = 25150012
    HALL_GATEKEEPERS[31926] = 25150013
    HALL_GATEKEEPERS[31927] = 25150014
    HALL_GATEKEEPERS[31928] = 25150015
    HALL_GATEKEEPERS[31929] = 25150016
    HALL_GATEKEEPERS[31930] = 25150002
    HALL_GATEKEEPERS[31931] = 25150003
    HALL_GATEKEEPERS[31932] = 25150004
    HALL_GATEKEEPERS[31933] = 25150005
    HALL_GATEKEEPERS[31934] = 25150006
    HALL_GATEKEEPERS[31935] = 25150032
    HALL_GATEKEEPERS[31936] = 25150033
    HALL_GATEKEEPERS[31937] = 25150034
    HALL_GATEKEEPERS[31938] = 25150035
    HALL_GATEKEEPERS[31939] = 25150036
    HALL_GATEKEEPERS[31940] = 25150022
    HALL_GATEKEEPERS[31941] = 25150023
    HALL_GATEKEEPERS[31942] = 25150024
    HALL_GATEKEEPERS[31943] = 25150025
    HALL_GATEKEEPERS[31944] = 25150026

    KEY_BOX_NPC[18120] = 31455
    KEY_BOX_NPC[18121] = 31455
    KEY_BOX_NPC[18122] = 31455
    KEY_BOX_NPC[18123] = 31455
    KEY_BOX_NPC[18124] = 31456
    KEY_BOX_NPC[18125] = 31456
    KEY_BOX_NPC[18126] = 31456
    KEY_BOX_NPC[18127] = 31456
    KEY_BOX_NPC[18128] = 31457
    KEY_BOX_NPC[18129] = 31457
    KEY_BOX_NPC[18130] = 31457
    KEY_BOX_NPC[18131] = 31457
    KEY_BOX_NPC[18149] = 31458
    KEY_BOX_NPC[18150] = 31459
    KEY_BOX_NPC[18151] = 31459
    KEY_BOX_NPC[18152] = 31459
    KEY_BOX_NPC[18153] = 31459
    KEY_BOX_NPC[18154] = 31460
    KEY_BOX_NPC[18155] = 31460
    KEY_BOX_NPC[18156] = 31460
    KEY_BOX_NPC[18157] = 31460
    KEY_BOX_NPC[18158] = 31461
    KEY_BOX_NPC[18159] = 31461
    KEY_BOX_NPC[18160] = 31461
    KEY_BOX_NPC[18161] = 31461
    KEY_BOX_NPC[18162] = 31462
    KEY_BOX_NPC[18163] = 31462
    KEY_BOX_NPC[18164] = 31462
    KEY_BOX_NPC[18165] = 31462
    KEY_BOX_NPC[18183] = 31463
    KEY_BOX_NPC[18184] = 31464
    KEY_BOX_NPC[18212] = 31465
    KEY_BOX_NPC[18213] = 31465
    KEY_BOX_NPC[18214] = 31465
    KEY_BOX_NPC[18215] = 31465
    KEY_BOX_NPC[18216] = 31466
    KEY_BOX_NPC[18217] = 31466
    KEY_BOX_NPC[18218] = 31466
    KEY_BOX_NPC[18219] = 31466

    VICTIM[18150] = 18158
    VICTIM[18151] = 18159
    VICTIM[18152] = 18160
    VICTIM[18153] = 18161
    VICTIM[18154] = 18162
    VICTIM[18155] = 18163
    VICTIM[18156] = 18164
    VICTIM[18157] = 18165
  end

  private def load_mysterious_box
    MYSTERIOUS_BOX_SPAWNS.clear

    begin
      sql = "SELECT id, count, npc_templateid, locx, locy, locz, heading, respawn_delay, key_npc_id FROM four_sepulchers_spawnlist Where spawntype = ? ORDER BY id"
      GameDB.each(sql, 0) do |rs|
        template_id = rs.get_i32(:"npc_templateid")
        count = rs.get_i32(:"count")
        x = rs.get_i32(:"locx")
        y = rs.get_i32(:"locy")
        z = rs.get_i32(:"locz")
        heading = rs.get_i32(:"heading")
        respawn_delay = rs.get_i32(:"respawn_delay")
        sp = L2Spawn.new(template_id)
        sp.amount = count
        sp.x, sp.y, sp.z = x, y, z
        sp.heading = heading
        sp.respawn_delay = respawn_delay
        SpawnTable.add_new_spawn(sp, false)
        key_npc_id = rs.get_i32(:"key_npc_id")

        MYSTERIOUS_BOX_SPAWNS[key_npc_id] = sp
      end
    rescue e
      error e
    end

    info { "Loaded #{MYSTERIOUS_BOX_SPAWNS.size} Mysterious - Box spawns." }
  end

  private def init_key_box_spawns
    KEY_BOX_NPC.each do |key, val|
      begin
        sp = L2Spawn.new(val)
        sp.amount = 1
        sp.x, sp.y, sp.z = 0, 0, 0
        sp.heading = 0
        sp.respawn_delay = 3600
        SpawnTable.add_new_spawn(sp, false)
        KEY_BOX_SPAWNS[key] = sp
      rescue e
        error e
      end
    end
  end

  private def load_physical_monsters
    load_any_monsters(PHYSICAL_MONSTERS, 1, "physical monster type")
  end

  private def load_magical_monsters
    load_any_monsters(MAGICAL_MONSTERS, 2, "magical monster type")
  end

  private def load_duke_monsters
    ARCHON_SPAWNED.clear
    load_any_monsters(DUKE_FINAL_MOBS, 5, "Church of duke monster")
    DUKE_FINAL_MOBS.each_key { |k| ARCHON_SPAWNED[k] = false }
  end

  private def load_emperors_grave_monsters
    load_any_monsters(EMPERORS_GRAVE_NPCS, 6, "Emperor's grave NPC")
  end

  private def load_any_monsters(map, type, name)
    map.clear

    loaded = 0

    sql = "SELECT Distinct key_npc_id FROM four_sepulchers_spawnlist Where spawntype = ? ORDER BY key_npc_id"
    GameDB.each(sql, type) do |rs1|
      key_npc_id = rs1.get_i32("key_npc_id")
      spawns = [] of L2Spawn
      sql = "SELECT id, count, npc_templateid, locx, locy, locz, heading, respawn_delay, key_npc_id FROM four_sepulchers_spawnlist Where key_npc_id = ? and spawntype = ? ORDER BY id"
      GameDB.each(sql, key_npc_id, type) do |rs2|
        template_id = rs2.get_i32("npc_templateid")
        sp = L2Spawn.new(template_id)
        sp.amount = rs2.get_i32("count")
        sp.x = rs2.get_i32("locx")
        sp.y = rs2.get_i32("locy")
        sp.z = rs2.get_i32("locz")
        sp.heading = rs2.get_i32("heading")
        sp.respawn_delay = rs2.get_i32("respawn_delay")
        SpawnTable.add_new_spawn(sp, false)
        spawns << sp
        loaded &+= 1
      end
      map[key_npc_id] = spawns
    end

    info "Loaded #{loaded} #{name} spawns."
  rescue e
    error e
  end

  private def init_location_shadow_spawns
    loc_no = Rnd.rand(4)
    gatekeeper = {
      31929,
      31934,
      31939,
      31944
    }
    SHADOW_SPAWNS.clear

    4.times do |i|
      begin
        sp = L2Spawn.new(SHADOW_SPAWN_LOC[loc_no][i][0])
        sp.amount = 1
        sp.x = SHADOW_SPAWN_LOC[loc_no][i][1]
        sp.y = SHADOW_SPAWN_LOC[loc_no][i][2]
        sp.z = SHADOW_SPAWN_LOC[loc_no][i][3]
        sp.heading = SHADOW_SPAWN_LOC[loc_no][i][4]
        SpawnTable.add_new_spawn(sp, false)
        SHADOW_SPAWNS[gatekeeper[i]] = sp
      rescue e
        error e
      end
    end
  end

  private def init_executioner_spawns
    VICTIM.each do |key_npc_id, val|
      begin
        sp = L2Spawn.new(val)
        sp.amount = 0
        sp.x, sp.y, sp.z, sp.heading = 0, 0, 0, 0
        sp.respawn_delay = 3600
        SpawnTable.add_new_spawn(sp, false)
        EXECUTIONER_SPAWNS[key_npc_id] = sp
      rescue e
        error e
      end
    end
  end

  def try_entry(npc : L2Npc, pc : L2PcInstance)
    sync do
      unless host_quest = QuestManager.get_quest(QUEST_ID)
        warn { "Couldn't find quest #{QUEST_ID}." }
        return
      end

      case npc_id = npc.id
      when 31921..31924
        # ID ok
      else
        unless pc.gm?
          warn { "Player #{pc.name} (#{pc.l2id}) tried to cheat in four sepulchers." }
          Util.punish(pc, "tried to enter four sepulchers with an invalid npc id (#{npc_id}).")
        end
        return
      end

      if HALL_IN_USE[npc_id]
        show_html_file(pc, "#{npc_id}-FULL.htm", npc, nil)
        return
      end

      if Config.fs_party_member_count > 1
        party = pc.party
        if party.nil? || party.size < Config.fs_party_member_count
          show_html_file(pc, "#{npc_id}-SP.htm", npc, nil)
          return
        end

        unless party.leader?(pc)
          show_html_file(pc, "#{npc_id}-NL.htm", npc, nil)
          return
        end

        party.members.each do |m|
          qs = m.get_quest_state(host_quest.name)
          if qs.nil? || (!qs.started? && !qs.completed?)
            show_html_file(pc, "#{npc_id}-NS.htm", npc, m)
            return
          end

          unless m.inventory.get_item_by_item_id(ENTRANCE_PASS)
            show_html_file(pc, "#{npc_id}-SE.htm", npc, m)
            return
          end

          if m.weight_penalty >= 3 # I think it should check 'm' rather than 'pc'
            m.send_packet(SystemMessageId::INVENTORY_LESS_THAN_80_PERCENT)
            return
          end
        end
      elsif Config.fs_party_member_count <= 1 && (party = pc.party)
        unless party.leader?(pc)
          show_html_file(pc, "#{npc_id}-NL.htm", npc, nil)
          return
        end

        party.members.each do |m|
          qs = m.get_quest_state(host_quest.name)
          if qs.nil? || (!qs.started? && !qs.completed?)
            show_html_file(pc, "#{npc_id}-NS.htm", npc, m)
            return
          end

          unless m.inventory.get_item_by_item_id(ENTRANCE_PASS)
            show_html_file(pc, "#{npc_id}-SE.htm", npc, m)
            return
          end

          if m.weight_penalty >= 3 # I think it should check 'm' rather than 'pc'
            m.send_packet(SystemMessageId::INVENTORY_LESS_THAN_80_PERCENT)
            return
          end
        end
      else
        qs = pc.get_quest_state(host_quest.name)
        if qs.nil? || (!qs.started? && !qs.completed?)
          show_html_file(pc, "#{npc_id}-NS.htm", npc, pc)
          return
        end

        unless pc.inventory.get_item_by_item_id(ENTRANCE_PASS)
          show_html_file(pc, "#{npc_id}-SE.htm", npc, pc)
          return
        end

        if pc.weight_penalty >= 3
          pc.send_packet(SystemMessageId::INVENTORY_LESS_THAN_80_PERCENT)
          return
        end
      end

      unless entry_time?
        show_html_file(pc, "#{npc_id}-NE.htm", npc, nil)
        return
      end

      show_html_file(pc, "#{npc_id}-OK.htm", npc, nil)

      entry(npc_id, pc)
    end
  end

  private def entry(npc_id : Int32, pc : L2PcInstance)
    loc = START_HALL_SPAWNS[npc_id]

    if Config.fs_party_member_count > 1 && (party = pc.party)
      members = Array(L2PcInstance).new(party.size)
      party.members.each do |m|
        if m.alive? && Util.in_range?(700, pc, m, true)
          members << m
        end
      end

      members.each do |m|
        GrandBossManager.get_zone(loc[0], loc[1], loc[2]).not_nil!.allow_player_entry(m, 30)
        drift_x = rand(-80..80)
        drift_y = rand(-80..80)
        m.tele_to_location(loc[0] + drift_x, loc[1] + drift_y, loc[2])
        m.destroy_item_by_item_id("Quest", ENTRANCE_PASS, 1, m, true)
        unless m.inventory.get_item_by_item_id(ANTIQUE_BROOCH)
          m.add_item("Quest", USED_PASS, 1, m, true)
        end

        if halls_key = m.inventory.get_item_by_item_id(CHAPEL_KEY)
          m.destroy_item_by_item_id("Quest", CHAPEL_KEY, halls_key.count, m, true)
        end
      end

      CHALLENGERS[npc_id] = pc

      HALL_IN_USE[npc_id] = true
    end

    if Config.fs_party_member_count <= 1 && (party = pc.party)
      members = Array(L2PcInstance).new(party.size)
      party.members.each do |m|
        if m.alive? && Util.in_range?(700, pc, m, true)
          members << m
        end
      end

      members.each do |m|
        GrandBossManager.get_zone(loc[0], loc[1], loc[2]).not_nil!.allow_player_entry(m, 30)
        drift_x = rand(-80..80)
        drift_y = rand(-80..80)
        m.tele_to_location(loc[0] + drift_x, loc[1] + drift_y, loc[2])
        m.destroy_item_by_item_id("Quest", ENTRANCE_PASS, 1, m, true)
        unless m.inventory.get_item_by_item_id(ANTIQUE_BROOCH)
          m.add_item("Quest", USED_PASS, 1, m, true)
        end

        if halls_key = m.inventory.get_item_by_item_id(CHAPEL_KEY)
          m.destroy_item_by_item_id("Quest", CHAPEL_KEY, halls_key.count, m, true)
        end
      end

      CHALLENGERS[npc_id] = pc

      HALL_IN_USE[npc_id] = true
    else
      GrandBossManager.get_zone(loc[0], loc[1], loc[2]).not_nil!.allow_player_entry(pc, 30)
      drift_x = rand(-80..80)
      drift_y = rand(-80..80)
      pc.tele_to_location(loc[0] + drift_x, loc[1] + drift_y, loc[2])
      pc.destroy_item_by_item_id("Quest", ENTRANCE_PASS, 1, pc, true)
      unless pc.inventory.get_item_by_item_id(ANTIQUE_BROOCH)
        pc.add_item("Quest", USED_PASS, 1, pc, true)
      end

      if halls_key = pc.inventory.get_item_by_item_id(CHAPEL_KEY)
        pc.destroy_item_by_item_id("Quest", CHAPEL_KEY, halls_key.count, pc, true)
      end

      CHALLENGERS[npc_id] = pc

      HALL_IN_USE[npc_id] = true
    end
  end

  def spawn_mysterious_box(npc_id : Int32)
    unless attack_time?
      return
    end

    if sp = MYSTERIOUS_BOX_SPAWNS[npc_id]?
      ALL_MOBS << sp.do_spawn
      sp.stop_respawn
    end
  end

  def spawn_monster(npc_id : Int32)
    unless attack_time?
      return
    end

    mobs = Array(L2SepulcherMonsterInstance).new
    if Rnd.rand(2) == 0
      monster_list = PHYSICAL_MONSTERS[npc_id]?
    else
      monster_list = MAGICAL_MONSTERS[npc_id]?
    end

    if monster_list
      spawn_key_box_mob = false
      spawned_key_box_mob = false

      monster_list.each do |sp|
        if spawned_key_box_mob
          spawn_key_box_mob = false
        else
          case npc_id
          when 31469, 31474, 31479, 31484
            if Rnd.rand(48) == 0
              spawn_key_box_mob = true
            end
          else
            spawn_key_box_mob = false
          end
        end

        mob = nil

        if spawn_key_box_mob
          begin
            key_box_mob_spawn = L2Spawn.new(18149)
            key_box_mob_spawn.amount = 1
            key_box_mob_spawn.location = sp.location
            key_box_mob_spawn.respawn_delay = 3600
            SpawnTable.add_new_spawn(key_box_mob_spawn, false)
            mob = key_box_mob_spawn.do_spawn.as(L2SepulcherMonsterInstance)
            key_box_mob_spawn.stop_respawn
          rescue e
            error e
          end
        else
          mob = sp.do_spawn.as(L2SepulcherMonsterInstance)
          sp.stop_respawn
        end

        if mob
          mob.mysterious_box_id = npc_id
          case npc_id
          when 31469, 31472, 31474, 31477, 31479, 31482, 31484, 31487
            mobs << mob
          end

          ALL_MOBS << mob
        end
      end

      case npc_id
      when 31469, 31474, 31479, 31484
        VISCOUNT_MOBS[npc_id] = mobs
      when 31472, 31477, 31482, 31487
        DUKE_MOBS[npc_id] = mobs
      end
    end
  end

  def viscount_mobs_annihilated?(npc_id : Int32) : Bool
    sync do
      unless mobs = VISCOUNT_MOBS[npc_id]?
        return true
      end

      mobs.all? &.dead?
    end
  end

  def duke_mobs_annihilated?(npc_id : Int32) : Bool
    sync do
      unless mobs = DUKE_MOBS[npc_id]?
        return true
      end

      mobs.all? &.dead?
    end
  end

  def spawn_key_box(npc : L2Npc)
    unless attack_time?
      return
    end

    if sp = KEY_BOX_SPAWNS[npc.id]?
      sp.amount = 1
      sp.x, sp.y, sp.z = npc.xyz
      sp.heading = npc.heading
      sp.respawn_delay = 3600
      ALL_MOBS << sp.do_spawn
      sp.stop_respawn
    end
  end

  def spawn_executioner_of_halisha(npc : L2Npc)
    unless attack_time?
      return
    end

    if sp = EXECUTIONER_SPAWNS[npc.id]?
      sp.amount = 1
      sp.x, sp.y, sp.z = npc.xyz
      sp.heading = npc.heading
      sp.respawn_delay = 3600
      ALL_MOBS << sp.do_spawn
      sp.stop_respawn
    end
  end

  def spawn_archon_of_halisha(npc_id : Int32)
    unless attack_time?
      return
    end

    if ARCHON_SPAWNED[npc_id]?
      return
    end

    if monster_list = DUKE_FINAL_MOBS[npc_id]?
      monster_list.each do |sp|
        mob = sp.do_spawn.as?(L2SepulcherMonsterInstance)
        sp.stop_respawn
        if mob
          mob.mysterious_box_id = npc_id
          ALL_MOBS << mob
        end
      end

      ARCHON_SPAWNED[npc_id] = true
    end
  end

  def spawn_emperors_grave_npc(npc_id : Int32)
    unless attack_time?
      return
    end

    if monster_list = EMPERORS_GRAVE_NPCS[npc_id]?
      monster_list.each do |sp|
        ALL_MOBS << sp.do_spawn
        sp.stop_respawn
      end
    end
  end

  def location_shadow_spawns
    loc_no = Rnd.rand(4)
    gatekeeper = {31929, 31934, 31939, 31944}

    4.times do |i|
      begin
        key_npc_id = gatekeeper[i]
        sp = SHADOW_SPAWNS[key_npc_id]
        sp.amount = 1
        sp.x = SHADOW_SPAWN_LOC.dig(loc_no, i, 1)
        sp.y = SHADOW_SPAWN_LOC.dig(loc_no, i, 2)
        sp.z = SHADOW_SPAWN_LOC.dig(loc_no, i, 3)
        sp.heading = SHADOW_SPAWN_LOC.dig(loc_no, i, 4)
        SHADOW_SPAWNS[key_npc_id] = sp
      rescue e
        error e
      end
    end
  end

  def spawn_shadow(npc_id : Int32)
    unless attack_time?
      return
    end

    if sp = SHADOW_SPAWNS[npc_id]?
      mob = sp.do_spawn.as?(L2SepulcherMonsterInstance)
      sp.stop_respawn

      if mob
        mob.mysterious_box_id = npc_id
        ALL_MOBS << mob
      end
    end
  end

  def delete_all_mobs
    ALL_MOBS.each do |mob|
      begin
        mob.spawn?.try &.stop_respawn
        mob.delete_me
      rescue e
        error e
      end
    end

    ALL_MOBS.clear
  end

  private def close_all_doors
    HALL_GATEKEEPERS.each_value do |door_id|
      begin
        if door = DoorData.get_door(door_id)
          door.close_me
        else
          warn { "Door with id #{door_id} not found." }
        end
      rescue e
        error e
      end
    end
  end

  private def minute_select(min : Int8) : Int8
    if min.to_f % 5 != 0
      case min
      when 6, 7
        min = 5i8
      when 8, 9, 11, 12
        min = 10i8
      when 13, 14, 16, 17
        min = 15i8
      when 18, 19, 21, 22
        min = 20i8
      when 23, 24, 26, 27
        min = 25i8
      when 28, 29, 31, 32
        min = 30i8
      when 33, 34, 36, 37
        min = 35i8
      when 38, 39, 41, 42
        min = 40i8
      when 43, 44, 46, 47
        min = 45i8
      when 48, 49, 51, 52
        min = 50i8
      when 53, 54, 56, 57
        min = 55i8
      end
    end

    min
  end

  def manager_say(min : Int8)
    if attack_time?
      if min < 5
        return # don't shout when < 5 minutes
      end

      min = minute_select(min)


      if min == 90
        msg = NpcString::GAME_OVER_THE_TELEPORT_WILL_APPEAR_MOMENTARILY
      else
        msg = NpcString::MINUTES_HAVE_PASSED
      end

      MANAGERS.each do |temp|
        unless last = temp.last_spawn.as?(L2SepulcherNpcInstance)
          warn { "#{temp.last_spawn} is not a L2SepulcherNpcInstance." }
          next
        end

        unless HALL_IN_USE[temp.id]
          next
        end

        last.say_in_shout(msg)
      end
    elsif entry_time?
      msg1 = NpcString::YOU_MAY_NOW_ENTER_THE_SEPULCHER
      msg2 = NpcString::IF_YOU_PLACE_YOUR_HAND_ON_THE_STONE_STATUE_IN_FRONT_OF_EACH_SEPULCHER_YOU_WILL_BE_ABLE_TO_ENTER

      MANAGERS.each do |temp|
        unless last = temp.last_spawn.as?(L2SepulcherNpcInstance)
          warn { "#{temp.last_spawn} is not a L2SepulcherNpcInstance." }
          next
        end

        unless HALL_IN_USE[temp.id]
          next
        end

        last.say_in_shout(msg1)
        last.say_in_shout(msg2)
      end
    end
  end

  def hall_gatekeepers : Hash(Int32, Int32)
    HALL_GATEKEEPERS
  end

  def show_html_file(pc : L2PcInstance, file : String, npc : L2Npc, m : L2PcInstance?)
    html = NpcHtmlMessage.new(npc.l2id)
    html.set_file(pc, "data/html/SepulcherNpc/" + file)
    if m
      html["%member%"] = m.name
    end
    pc.send_packet(html)
  end
end
