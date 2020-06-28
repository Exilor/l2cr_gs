class Scripts::Stage1 < AbstractInstance
  include XMLReader

  private class SOD1World < InstanceWorld
    getter players_inside = [] of L2PcInstance
    getter npc_list = {} of L2Npc => Bool
    getter lock = MyMutex.new
    property device_spawned_mob_count = 0
    property! tiat : L2MonsterInstance
  end

  private class SODSpawn
    property npc_id = 0
    property x = 0
    property y = 0
    property z = 0
    property h = 0
    property zone = 0
    property count = 0
    property? is_zone = false
    property? needed_next_flag = false
  end

  private TEMPLATE_ID = 110
  private MIN_PLAYERS = 27
  private MAX_PLAYERS = 45
  private MIN_LEVEL = 75
  private MAX_DEVICE_SPAWNED_MOB_COUNT = 100 # prevent too many mob spawns

  private SPAWN_ZONE_LIST = {} of Int32 => L2Territory
  private SPAWN_LIST = {} of Int32 => Array(SODSpawn)
  private MUST_KILL_MOBS_ID = [] of Int32

  # teleports
  private ENTER_TELEPORT_1 = Location.new(-242759, 219981, -9986)
  private ENTER_TELEPORT_2 = Location.new(-245800, 220488, -12112)
  private CENTER_TELEPORT = Location.new(-245802, 220528, -12104)

  # Traps/Skills
  private TRAP_HOLD = SkillHolder.new(4186, 9) # 18720-18728
  private TRAP_STUN = SkillHolder.new(4072, 10) # 18729-18736
  private TRAP_DAMAGE = SkillHolder.new(5340, 4) # 18737-18770
  private TRAP_18771_NPCS = {
    22541,
    22544,
    22541,
    22544
  }
  private TRAP_OTHER_NPCS = {
    22546,
    22546,
    22538,
    22537
  }

  # NPCs
  private ALENOS = 32526
  private TELEPORT = 32601

  # mobs
  private OBELISK = 18776
  private POWERFUL_DEVICE = 18777
  private THRONE_POWERFUL_DEVICE = 18778
  private SPAWN_DEVICE = 18696
  private TIAT = 29163
  private TIAT_GUARD = 29162
  private TIAT_GUARD_NUMBER = 5
  private TIAT_VIDEO_NPC = 29169
  private  MOVE_TO_TIAT = Location.new(-250403, 207273, -11952, 16384)
  private  MOVE_TO_DOOR = Location.new(-251432, 214905, -12088, 16384)

  # TODO: handle this better
  private SPAWN_MOB_IDS = {
    22536,
    22537,
    22538,
    22539,
    22540,
    22541,
    22542,
    22543,
    22544,
    22547,
    22550,
    22551,
    22552,
    22596
  }

  # Doors/Walls/Zones
  private ATTACKABLE_DOORS = {
    12240005,
    12240006,
    12240007,
    12240008,
    12240009,
    12240010,
    12240013,
    12240014,
    12240015,
    12240016,
    12240017,
    12240018,
    12240021,
    12240022,
    12240023,
    12240024,
    12240025,
    12240026,
    12240028,
    12240029,
    12240030
  }

  private ENTRANCE_ROOM_DOORS = {
    12240001,
    12240002
  }
  private SQUARE_DOORS = {
    12240003,
    12240004,
    12240011,
    12240012,
    12240019,
    12240020
  }
  private SCOUTPASS_DOOR = 12240027
  private FORTRESS_DOOR = 12240030
  private THRONE_DOOR = 12240031

  def initialize
    super(self.class.simple_name, "gracia/instances")

    parse_datapack_file("spawnZones/seed_of_destruction.xml")

    add_start_npc(ALENOS, TELEPORT)
    add_talk_id(ALENOS, TELEPORT)
    add_attack_id(OBELISK, TIAT)
    add_spawn_id(OBELISK, POWERFUL_DEVICE, THRONE_POWERFUL_DEVICE, TIAT_GUARD)
    add_kill_id(
      OBELISK, POWERFUL_DEVICE, THRONE_POWERFUL_DEVICE, TIAT, SPAWN_DEVICE,
      TIAT_GUARD
    )
    add_kill_id(MUST_KILL_MOBS_ID)
    add_aggro_range_enter_id(TIAT_VIDEO_NPC)
    18771.upto(18774) do |i|
      add_trap_action_id(i)
    end
  end

  private def parse_document(doc, file)
    spawn_count = 0

    find_element(doc, "list") do |list|
        each_element(list) do |n, n_name|
        if n_name.casecmp?("npc")
          each_element(n) do |d, d_name|
            if d_name.casecmp?("spawn")
              unless npc_id = parse_int(d, "npcId", nil)
                error "Missing npc_id in npc List, skipping."
                next
              end

              unless flag = parse_int(d, "flag", nil)
                error { "Missing flag in npc List npc_id: #{npc_id}, skipping." }
                next
              end

              SPAWN_LIST[flag] ||= [] of SODSpawn

              each_element(d) do |cd, cd_name|
                if cd_name.casecmp?("loc")
                  spw = SODSpawn.new
                  spw.npc_id = npc_id

                  if tmp = parse_int(cd, "x", nil)
                    spw.x = tmp
                  else
                    next
                  end
                  if tmp = parse_int(cd, "y", nil)
                    spw.y = tmp
                  else
                    next
                  end
                  if tmp = parse_int(cd, "z", nil)
                    spw.z = tmp
                  else
                    next
                  end
                  if tmp = parse_int(cd, "heading", nil)
                    spw.h = tmp
                  else
                    next
                  end
                  tmp = parse_bool(cd, "mustKill", nil)
                  unless tmp.nil?
                    spw.needed_next_flag = tmp
                  end
                  if spw.needed_next_flag?
                    MUST_KILL_MOBS_ID << npc_id
                  end
                  SPAWN_LIST[flag] << spw
                  spawn_count &+= 1
                elsif cd_name.casecmp?("zone")
                  spw = SODSpawn.new
                  spw.npc_id = npc_id
                  spw.is_zone = true

                  if tmp = parse_int(cd, "id", nil)
                    spw.zone = tmp
                  else
                    next
                  end
                  if tmp = parse_int(cd, "count", nil)
                    spw.count = tmp
                  else
                    next
                  end
                  tmp = parse_bool(cd, "mustKill", nil)
                  unless tmp.nil?
                    spw.needed_next_flag = tmp
                  end
                  if spw.needed_next_flag?
                    MUST_KILL_MOBS_ID << npc_id
                  end
                  SPAWN_LIST[flag] << spw
                  spawn_count &+= 1
                end
              end
            end
          end
        elsif n_name.casecmp?("spawnZones")
          find_element(n, "zone") do |d|
            unless id = parse_int(d, "id", nil)
              error "Missing id in spawnZones List, skipping."
              next
            end

            unless minz = parse_int(d, "minZ", nil)
              error { "Missing minZ in spawnZones List id: #{id}, skipping." }
              next
            end

            unless maxz = parse_int(d, "maxZ", nil)
              error { "Missing maxZ in spawnZones List id: #{id}, skipping." }
              next
            end

            ter = L2Territory.new(id)

            each_element(d) do |cd, cd_name|
              if cd_name.casecmp?("point")
                unless x = parse_int(cd, "x", nil)
                  next
                end
                unless y = parse_int(cd, "y", nil)
                  next
                end

                ter.add(x, y, minz, maxz, 0)
              end
            end

            SPAWN_ZONE_LIST[id] = ter
          end
        end
      end
    end

    info { "Loaded #{spawn_count} spawn data." }
    info { "Loaded #{SPAWN_ZONE_LIST.size} spawn zone data." }
  end

  private def check_conditions(pc)
    if pc.override_instance_conditions?
      return true
    end

    unless party = pc.party
      pc.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end

    cc = party.command_channel
    if cc.nil?
      pc.send_packet(SystemMessageId::NOT_IN_COMMAND_CHANNEL_CANT_ENTER)
      return false
    elsif cc.leader != pc
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    elsif !cc.size.between?(MIN_PLAYERS, MAX_PLAYERS)
      pc.send_packet(SystemMessageId::PARTY_EXCEEDED_THE_LIMIT_CANT_ENTER)
      return false
    end

    cc.members.each do |m|
      if m.level < MIN_LEVEL
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      unless Util.in_range?(1000, pc, m, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      if Time.ms < InstanceManager.get_instance_time(m.l2id, TEMPLATE_ID)
        sm = SystemMessage.c1_may_not_re_enter_yet
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
    end

    true
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      party = pc.party
      if party.nil?
        manage_player_enter(pc, world.as(SOD1World))
      elsif cc = party.command_channel
        cc.members.each do |m|
          manage_player_enter(m, world.as(SOD1World))
        end
      else
        party.members.each do |m|
          manage_player_enter(m, world.as(SOD1World))
        end
      end

      spawn_state(world.as(SOD1World))

      InstanceManager.get_instance(world.instance_id).not_nil!.doors.each do |door|
        if ATTACKABLE_DOORS.includes?(door.id)
          door.attackable_door = true
        end
      end
    else
      teleport_player(pc, ENTER_TELEPORT_1, world.instance_id)
    end
  end

  private def manage_player_enter(player, world)
    world.players_inside << player
    world.add_allowed(player.l2id)
    teleport_player(player, ENTER_TELEPORT_1, world.instance_id, false)
  end

  private def check_kill_progress(mob, world)
    if world.npc_list.has_key?(mob)
      world.npc_list[mob] = true
    end

    world.npc_list.local_each_value.all?
  end

  private def spawn_flagged_npcs(world, flag)
    if world.lock.lock?
      begin
        SPAWN_LIST[flag].each do |spw|
          if spw.is_zone?
            spw.count.times do |i|
              if tmp = SPAWN_ZONE_LIST[spw.zone]
                if loc = tmp.random_point
                  private_spawn(world, spw.npc_id, loc.x, loc.y, GeoData.get_spawn_height(loc), Rnd.rand(65535), spw.needed_next_flag?)
                end
              else
                warn { "Missing zone #{spw.zone}." }
              end
            end
          else
            private_spawn(world, spw.npc_id, spw.x, spw.y, spw.z, spw.h, spw.needed_next_flag?)
          end
        end
      ensure
        world.lock.unlock
      end
    end
  end

  private def spawn_state(world)
    if world.lock.lock?
      begin
        world.npc_list.clear
        case world.status
        when 0
          spawn_flagged_npcs(world, 0)
        when 1
          manage_screen_msg(world, NpcString::THE_ENEMIES_HAVE_ATTACKED_EVERYONE_COME_OUT_AND_FIGHT_URGH)
          ENTRANCE_ROOM_DOORS.each do |i|
            open_door(i, world.instance_id)
          end
          spawn_flagged_npcs(world, 1)
        when 2, 3
          # handled elsewhere
          return true
        when 4
          manage_screen_msg(world, NpcString::OBELISK_HAS_COLLAPSED_DONT_LET_THE_ENEMIES_JUMP_AROUND_WILDLY_ANYMORE)
          SQUARE_DOORS.each do |i|
            open_door(i, world.instance_id)
          end
          spawn_flagged_npcs(world, 4)
        when 5
          open_door(SCOUTPASS_DOOR, world.instance_id)
          spawn_flagged_npcs(world, 3)
          spawn_flagged_npcs(world, 5)
        when 6
          open_door(THRONE_DOOR, world.instance_id)
        when 7
          spawn_flagged_npcs(world, 7)
        when 8
          manage_screen_msg(world, NpcString::COME_OUT_WARRIORS_PROTECT_SEED_OF_DESTRUCTION)
          world.device_spawned_mob_count = 0
          spawn_flagged_npcs(world, 8)
        when 9
          # instance end
        end

        world.inc_status
        return true
      ensure
        world.lock.unlock
      end
    end

    false
  end

  private def private_spawn(world, npc_id, x, y, z, h, add_to_kill_table)
    # traps
    if npc_id.between?(18720, 18774)
      if npc_id <= 18728
        skill = TRAP_HOLD.skill
      elsif npc_id <= 18736
        skill = TRAP_STUN.skill
      elsif npc_id <= 18770
        skill = TRAP_DAMAGE.skill
      end

      add_trap(npc_id, x, y, z, h, skill, world.instance_id)
      return
    end
    npc = add_spawn(npc_id, x, y, z, h, false, 0, false, world.instance_id)
    if add_to_kill_table
      world.npc_list[npc] = false
    end
    npc.no_random_walk = true
    if npc.is_a?(L2Attackable)
      npc.can_see_through_silent_move = true
    end
    if npc_id == TIAT_VIDEO_NPC
      start_quest_timer("DoorCheck", 10000, npc, nil)
    elsif npc_id == SPAWN_DEVICE
      npc.disable_core_ai(true)
      start_quest_timer("Spawn", 10000, npc, nil, true)
    elsif npc_id == TIAT
      npc.immobilized = true
      world.tiat = npc.as(L2MonsterInstance)
      TIAT_GUARD_NUMBER.times do |i|
        add_minion(world.tiat, TIAT_GUARD)
      end
    end
  end

  private def manage_screen_msg(world, npc_str)
    world.players_inside.each do |pc|
      if pc.instance_id == world.instance_id
        show_on_screen_msg(pc, npc_str, 2, 5000)
      end
    end
  end

  def on_spawn(npc)
    if npc.id == TIAT_GUARD
      start_quest_timer("GuardThink", 2500 + Rnd.rand(-200..200), npc, nil, true)
    else
      npc.disable_core_ai(true)
    end

    super
  end

  def on_aggro_range_enter(npc, player, is_summon)
    if !is_summon && player
      world = InstanceManager.get_world(player.instance_id)
      if world.is_a?(SOD1World)
        if world.status == 7
          if spawn_state(world)
            world.allowed.each do |l2id|
              if pl = L2World.get_player(l2id)
                pl.show_quest_movie(5)
              end
            end
            npc.delete_me
          end
        end
      end
    end

    nil
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(SOD1World)
      if world.status == 2 && npc.id == OBELISK
        world.status = 4
        spawn_flagged_npcs(world, 3)
      elsif world.status == 3 && npc.id == OBELISK
        world.status = 4
        spawn_flagged_npcs(world, 2)
      elsif world.status <= 8 && npc.id == TIAT
        if npc.current_hp < npc.max_hp / 2
          if spawn_state(world)
            start_quest_timer("TiatFullHp", 3000, npc, nil)
          end
        end
      end
    end


    nil
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!

    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(SOD1World)
      if event.casecmp?("Spawn")
        if target = L2World.get_player(world.allowed.sample)
          if world.device_spawned_mob_count < MAX_DEVICE_SPAWNED_MOB_COUNT
            if target.instance_id == npc.instance_id && target.alive?
              mob = add_spawn(SPAWN_MOB_IDS.sample, npc.spawn.location, false, 0, false, world.instance_id).as(L2Attackable)
              world.device_spawned_mob_count &+= 1
              mob.can_see_through_silent_move = true
              mob.set_running
              if world.status >= 7
                mob.set_intention(AI::MOVE_TO, MOVE_TO_TIAT)
              else
                mob.set_intention(AI::MOVE_TO, MOVE_TO_DOOR)
              end
            end
          end
        end
      elsif event.casecmp?("DoorCheck")
        tmp = get_door(FORTRESS_DOOR, npc.instance_id).not_nil!
        if tmp.current_hp < tmp.max_hp
          world.device_spawned_mob_count = 0
          spawn_flagged_npcs(world, 6)
          manage_screen_msg(world, NpcString::ENEMIES_ARE_TRYING_TO_DESTROY_THE_FORTRESS_EVERYONE_DEFEND_THE_FORTRESS)
        else
          start_quest_timer("DoorCheck", 10000, npc, nil)
        end
      elsif event.casecmp?("TiatFullHp")
        if !npc.stunned? && !npc.invul?
          npc.current_hp = npc.max_hp.to_f
        end
      elsif event.casecmp?("BodyGuardThink")
        if hated = npc.as(L2Attackable).most_hated
          dist = Util.calculate_distance(hated.x_destination.to_f, hated.y_destination.to_f, 0, npc.spawn.x.to_f, npc.spawn.y.to_f, 0, false, false)
          if dist > 900
            npc.as(L2Attackable).reduce_hate(hated, npc.as(L2Attackable).get_hating(hated))
          end
          hated = npc.as(L2Attackable).most_hated
          if hated || npc.as(L2Attackable).get_hating(hated) < 5
            npc.as(L2Attackable).return_home
          end
        end
      end
    end

    ""
  end

  def on_kill(npc, player, is_summon)
    if npc.id == SPAWN_DEVICE
      cancel_quest_timer("Spawn", npc, nil)
      return ""
    end

    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(SOD1World)
      if world.status == 1
        if check_kill_progress(npc, world)
          spawn_state(world)
        end
      elsif world.status == 2
        if check_kill_progress(npc, world)
          world.inc_status
        end
      elsif world.status == 4 && npc.id == OBELISK
        spawn_state(world)
      elsif world.status == 5 && npc.id == POWERFUL_DEVICE
        if check_kill_progress(npc, world)
          spawn_state(world)
        end
      elsif world.status == 6 && npc.id == THRONE_POWERFUL_DEVICE
        if check_kill_progress(npc, world)
          spawn_state(world)
        end
      elsif world.status >= 7
        if npc.id == TIAT
          world.inc_status
          world.allowed.each do |l2id|
            if pl = L2World.get_player(l2id)
              pl.show_quest_movie(6)
            end
          end
          InstanceManager.get_instance(world.instance_id).not_nil!.npcs.each do |mob|
            mob.delete_me
          end

          GraciaSeedsManager.increase_sod_tiat_killed
          finish_instance(world)
        elsif npc.id == TIAT_GUARD
          add_minion(world.tiat, TIAT_GUARD)
        end
      end
    end

    ""
  end

  def on_talk(npc, pc)
    npc_id = npc.id
    get_quest_state!(pc)
    if npc_id == ALENOS
      world = InstanceManager.get_player_world(pc)
      if GraciaSeedsManager.sod_state == 1 || world.is_a?(SOD1World)
        enter_instance(pc, SOD1World.new, "SeedOfDestructionStage1.xml", TEMPLATE_ID)
      elsif GraciaSeedsManager.sod_state == 2
        teleport_player(pc, ENTER_TELEPORT_2, 0, false)
      end
    elsif npc_id == TELEPORT
      teleport_player(pc, CENTER_TELEPORT, pc.instance_id, false)
    end

    ""
  end

  def on_trap_action(trap, trigger, action)
    world = InstanceManager.get_world(trap.instance_id)
    if world.is_a?(SOD1World)
      case action
      when TrapAction::TRIGGERED
        if trap.id == 18771
          TRAP_18771_NPCS.each do |npc_id|
            add_spawn(npc_id, *trap.xyz, trap.heading, true, 0, true, world.instance_id)
          end
        else
          TRAP_OTHER_NPCS.each do |npc_id|
            add_spawn(npc_id, *trap.xyz, trap.heading, true, 0, true, world.instance_id)
          end
        end
      end

    end

    nil
  end
end
