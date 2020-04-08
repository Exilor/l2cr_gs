class Scripts::FinalEmperialTomb < AbstractInstance
  include XMLReader

  private class FETWorld < InstanceWorld
    getter lock = MyMutex.new
    getter demons = Concurrent::Array(L2MonsterInstance).new
    getter portraits = Concurrent::Map(L2MonsterInstance, Int32).new
    getter npc_list = Concurrent::Array(L2Npc).new
    property scarlet_x = 0
    property scarlet_y = 0
    property scarlet_z = 0
    property scarlet_h = 0
    property scarlet_a = 0
    property dark_choir_player_count = 0
    property song_task : Scheduler::DelayedTask?
    property song_effect_task : Scheduler::DelayedTask?
    property! on_song : FrintezzaSong
    property! frintezza_dummy : L2Npc?
    property! overhead_dummy : L2Npc?
    property! portrait_dummy1 : L2Npc?
    property! portrait_dummy3 : L2Npc?
    property! scarlet_dummy : L2Npc?
    property! frintezza : L2GrandBossInstance?
    property! active_scarlet : L2GrandBossInstance?
    property? video = false
  end

  private class FETSpawn
    property npc_id = 0
    property x = 0
    property y = 0
    property z = 0
    property heading = 0
    property zone = 0
    property count = 0
    property? is_zone = false
    property? needed_next_flag = false
  end

  private record FrintezzaSong, skill : SkillHolder, effect_skill : SkillHolder,
    song_name : NpcString, chance : Int32

  # NPCs
  private GUIDE = 32011
  private CUBE = 29061
  private SCARLET1 = 29046
  private SCARLET2 = 29047
  private FRINTEZZA = 29045
  private PORTRAITS = {
    29048,
    29049
  }
  private DEMONS = {
    29050,
    29051
  }
  private HALL_ALARM = 18328
  private HALL_KEEPER_CAPTAIN = 18329
  # Items
  private HALL_KEEPER_SUICIDAL_SOLDIER = 18333
  private DARK_CHOIR_PLAYER = 18339
  private AI_DISABLED_MOBS = {
    18328
  }
  private DEWDROP_OF_DESTRUCTION_ITEM_ID = 8556
  private FIRST_SCARLET_WEAPON = 8204
  private SECOND_SCARLET_WEAPON = 7903
  # Skills
  private DEWDROP_OF_DESTRUCTION_SKILL_ID = 2276
  private SOUL_BREAKING_ARROW_SKILL_ID = 2234
  private INTRO_SKILL = SkillHolder.new(5004)
  private FIRST_MORPH_SKILL = SkillHolder.new(5017)

  private FRINTEZZA_SONG_LIST = {
    FrintezzaSong.new(SkillHolder.new(5007, 1), SkillHolder.new(5008, 1), NpcString::REQUIEM_OF_HATRED, 5),
    FrintezzaSong.new(SkillHolder.new(5007, 2), SkillHolder.new(5008, 2), NpcString::RONDO_OF_SOLITUDE, 50),
    FrintezzaSong.new(SkillHolder.new(5007, 3), SkillHolder.new(5008, 3), NpcString::FRENETIC_TOCCATA, 70),
    FrintezzaSong.new(SkillHolder.new(5007, 4), SkillHolder.new(5008, 4), NpcString::FUGUE_OF_JUBILATION, 90),
    FrintezzaSong.new(SkillHolder.new(5007, 5), SkillHolder.new(5008, 5), NpcString::HYPNOTIC_MAZURKA, 100)
  }
  # Locations
  private ENTER_TELEPORT = Location.new(-88015, -141153, -9168)
  private MOVE_TO_CENTER = Location.new(-87904, -141296, -9168, 0)
  # Misc
  private TEMPLATE_ID = 136 # this is the client number
  private MIN_PLAYERS = 18
  private MAX_PLAYERS = 45
  private TIME_BETWEEN_DEMON_SPAWNS = 20000
  private MAX_DEMONS = 24
  private SPAWN_ZONE_LIST = {} of Int32 => L2Territory
  private SPAWN_LIST = {} of Int32 => Array(FETSpawn)
  private MUST_KILL_MOBS_ID = [] of Int32
  private FIRST_ROOM_DOORS = {
    17130051,
    17130052,
    17130053,
    17130054,
    17130055,
    17130056,
    17130057,
    17130058
  }
  private SECOND_ROOM_DOORS = {
    17130061,
    17130062,
    17130063,
    17130064,
    17130065,
    17130066,
    17130067,
    17130068,
    17130069,
    17130070
  }
  private FIRST_ROUTE_DOORS = {
    17130042,
    17130043
  }
  private SECOND_ROUTE_DOORS = {
    17130045,
    17130046
  }
  private PORTRAIT_SPAWNS = {
    {29048, -89381, -153981, -9168, 3368, -89378, -153968, -9168, 3368},
    {29048, -86234, -152467, -9168, 37656, -86261, -152492, -9168, 37656},
    {29049, -89342, -152479, -9168, -5152, -89311, -152491, -9168, -5152},
    {29049, -86189, -153968, -9168, 29456, -86217, -153956, -9168, 29456}
  }

  def initialize
    super(self.class.simple_name)

    parse_datapack_file("spawnZones/final_emperial_tomb.xml")

    add_attack_id(SCARLET1, FRINTEZZA)
    add_attack_id(PORTRAITS)
    add_start_npc(GUIDE, CUBE)
    add_talk_id(GUIDE, CUBE)
    add_kill_id(HALL_ALARM, HALL_KEEPER_CAPTAIN, DARK_CHOIR_PLAYER, SCARLET2)
    add_kill_id(PORTRAITS)
    add_kill_id(DEMONS)
    add_kill_id(MUST_KILL_MOBS_ID)
    add_spell_finished_id(HALL_KEEPER_SUICIDAL_SOLDIER)
  end

  private def parse_document(doc, file)
    spawn_count = 0

    doc.find_element("list") do |list|
      list.each_element do |n|
        if n.name.casecmp?("npc")
          n.find_element("spawn") do |d|
            npc_id = d["npcId"].to_i
            flag = d["flag"].to_i
            SPAWN_LIST[flag] ||= [] of FETSpawn
            d.each_element do |cd|
              if cd.name.casecmp?("loc")
                spw = FETSpawn.new
                spw.npc_id = npc_id
                next unless tmp = cd["x"]?
                spw.x = tmp.to_i
                next unless tmp = cd["y"]?
                spw.y = tmp.to_i
                next unless tmp = cd["z"]?
                spw.z = tmp.to_i
                next unless tmp = cd["heading"]?
                spw.heading = tmp.to_i
                if tmp = cd["mustKill"]?
                  spw.needed_next_flag = Bool.new(tmp)
                end
                if spw.needed_next_flag?
                  MUST_KILL_MOBS_ID << npc_id
                end
                SPAWN_LIST[flag] << spw
                spawn_count += 1
              elsif cd.name.casecmp?("zone")
                spw = FETSpawn.new
                spw.npc_id = npc_id
                spw.is_zone = true

                next unless tmp = cd["id"]?
                spw.zone = tmp.to_i
                next unless tmp = cd["count"]?
                spw.count = tmp.to_i
                if tmp = cd["mustKill"]?
                  spw.needed_next_flag = Bool.new(tmp)
                end
                if spw.needed_next_flag?
                  MUST_KILL_MOBS_ID << npc_id
                end
                SPAWN_LIST[flag] << spw
                spawn_count += 1
              end
            end
          end
        elsif n.name.casecmp?("spawnZones")
          n.find_element("zone") do |d|
            unless tmp = d["id"]?
              warn "Missing id in spawnZones list."
              next
            end
            id = tmp.to_i

            unless tmp = d["minZ"]?
              warn "Missing minZ in spawnZones list."
              next
            end
            min_z = tmp.to_i

            unless tmp = d["maxZ"]?
              warn "Missing maxZ in spawnZones list."
              next
            end
            max_z = tmp.to_i

            ter = L2Territory.new(id)

            d.find_element("point") do |cd|
              next unless tmp = cd["x"]?
              x = tmp.to_i
              next unless tmp = cd["y"]?
              y = tmp.to_i

              ter.add(x, y, min_z, max_z, 0)
            end

            SPAWN_ZONE_LIST[id] = ter
          end
        end
      end
    end

    info { "Loaded #{SPAWN_ZONE_LIST.size} spawn zones data." }
    info { "Loaded #{spawn_count} spawns data." }
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
    elsif pc.inventory.get_item_by_item_id(8073).nil?
      sm = SystemMessage.c1_item_requirement_not_sufficient
      sm.add_pc_name(pc)
      pc.send_packet(sm)
      return false
    elsif !cc.size.between?(MIN_PLAYERS, MAX_PLAYERS)
      pc.send_packet(SystemMessageId::PARTY_EXCEEDED_THE_LIMIT_CANT_ENTER)
      return false
    end
    cc.members.each do |m|
      if m.level < 80
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
      reenter_time = InstanceManager.get_instance_time(m.l2id, TEMPLATE_ID)
      if Time.ms < reenter_time
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
      control_status(world.as(FETWorld))
      party = pc.party
      cc = party.try &.command_channel
      if party.nil? || cc.nil?
        pc.destroy_item_by_item_id(name, DEWDROP_OF_DESTRUCTION_ITEM_ID, pc.inventory.get_inventory_item_count(DEWDROP_OF_DESTRUCTION_ITEM_ID, -1), nil, true)
        world.add_allowed(pc.l2id)
        teleport_player(pc, ENTER_TELEPORT, world.instance_id, false)
      else
        cc.members.each do |m|
          m.destroy_item_by_item_id(name, DEWDROP_OF_DESTRUCTION_ITEM_ID, m.inventory.get_inventory_item_count(DEWDROP_OF_DESTRUCTION_ITEM_ID, -1), nil, true)
          world.add_allowed(m.l2id)
          teleport_player(m, ENTER_TELEPORT, world.instance_id, false)
        end
      end
    else
      teleport_player(pc, ENTER_TELEPORT, world.instance_id, false)
    end
  end

  def check_kill_progress(mob, world)
    if idx = world.npc_list.index(mob)
      world.npc_list.delete_at(idx)
    end

    world.npc_list.empty?
  end

  private def spawn_flagged_npcs(world, flag)
    world.lock.synchronize do
      SPAWN_LIST[flag].each do |spw|
        if spw.is_zone?
          spw.count.times do |i|
            if SPAWN_ZONE_LIST.has_key?(spw.zone)
              if loc = SPAWN_ZONE_LIST[spw.zone].random_point
                do_spawn(world, spw.npc_id, loc.x, loc.y, GeoData.get_spawn_height(loc), Rnd.rand(65535), spw.needed_next_flag?)
              end
            else
              debug { "Missing zone: #{spw.zone}." }
            end
          end
        else
          do_spawn(world, spw.npc_id, spw.x, spw.y, spw.z, spw.heading, spw.needed_next_flag?)
        end
      end
    end
  end

  def control_status(world)
    world.lock.synchronize do
      debug { "Starting #{world.status}. status." }
      world.npc_list.clear
      case world.status
      when 0
        spawn_flagged_npcs(world, 0)
      when 1
        FIRST_ROUTE_DOORS.each do |door_id|
          open_door(door_id, world.instance_id)
        end
        spawn_flagged_npcs(world, world.status)
      when 2
        SECOND_ROUTE_DOORS.each do |door_id|
          open_door(door_id, world.instance_id)
        end
        ThreadPoolManager.schedule_general(IntroTask.new(self, world, 0), 600000)
      when 3 # first morph
        if task = world.song_effect_task
          task.cancel
          world.song_effect_task = nil
        end
        world.active_scarlet.invul = true
        if world.active_scarlet.casting_now?
          world.active_scarlet.abort_cast
        end
        handle_reenter_time(world)
        world.active_scarlet.do_cast(FIRST_MORPH_SKILL)
        ThreadPoolManager.schedule_general(SongTask.new(self, world, 2), 1500)
      when 4 # second morph
        world.video = true
        broadcast_packet(world, MagicSkillCancel.new(world.frintezza.l2id))
        if task = world.song_effect_task
          task.cancel
          world.song_effect_task = nil
        end
        world.song_effect_task = nil
        ThreadPoolManager.schedule_general(IntroTask.new(self, world, 23), 2000)
        ThreadPoolManager.schedule_general(IntroTask.new(self, world, 24), 2100)
      when 5 # raid success
        world.video = true
        broadcast_packet(world, MagicSkillCancel.new(world.frintezza.l2id))
        if task = world.song_task
          task.cancel
          world.song_task = nil
        end
        if task = world.song_effect_task
          task.cancel
          world.song_effect_task = nil
        end
        world.song_task = nil
        world.song_effect_task = nil
        ThreadPoolManager.schedule_general(IntroTask.new(self, world, 33), 500)
      when 6 # open doors
        InstanceManager.get_instance(world.instance_id).not_nil!.duration = 300000
        FIRST_ROOM_DOORS.each do |door_id|
          open_door(door_id, world.instance_id)
        end
        FIRST_ROUTE_DOORS.each do |door_id|
          open_door(door_id, world.instance_id)
        end
        SECOND_ROUTE_DOORS.each do |door_id|
          open_door(door_id, world.instance_id)
        end
        SECOND_ROOM_DOORS.each do |door_id|
          close_door(door_id, world.instance_id)
        end
      else
        # automatically added
      end


      world.inc_status
      return true
    end

    false
  end

  def do_spawn(world, npc_id, x, y, z, h, add_to_kill_table)
     npc = add_spawn(npc_id, x, y, z, h, false, 0, false, world.instance_id)
    if add_to_kill_table
      world.npc_list << npc
    end
    npc.no_random_walk = true
    if npc.is_a?(L2Attackable)
      npc.can_see_through_silent_move = true
    end
    if AI_DISABLED_MOBS.includes?(npc_id)
      npc.disable_core_ai(true)
    end
    if npc_id == DARK_CHOIR_PLAYER
      world.dark_choir_player_count += 1
    end
  end

  private struct DemonSpawnTask
    include Loggable

    initializer tomb : FinalEmperialTomb, world : FETWorld

    def call
      if InstanceManager.get_world(@world.instance_id) != @world || @world.portraits.empty?
        debug "Instance is deleted or all portraits have been killed."
        return
      end
      @world.portraits.each_value do |i|
        if @world.demons.size > MAX_DEMONS
          break
        end
        demon = @tomb.add_spawn(PORTRAIT_SPAWNS[i][0] + 2, PORTRAIT_SPAWNS[i][5], PORTRAIT_SPAWNS[i][6], PORTRAIT_SPAWNS[i][7], PORTRAIT_SPAWNS[i][8], false, 0, false, @world.instance_id).as(L2MonsterInstance)
        @tomb.update_known_list(@world, demon)
        @world.demons << demon
      end
      ThreadPoolManager.schedule_general(DemonSpawnTask.new(@tomb, @world), TIME_BETWEEN_DEMON_SPAWNS)
    end
  end

  private struct SoulBreakingArrow
    initializer npc : L2Npc

    def call
      @npc.script_value = 0
    end
  end

  private struct SongTask
    initializer tomb : FinalEmperialTomb, world : FETWorld, status : Int32

    def call
      if InstanceManager.get_world(@world.instance_id) != @world
        return
      end

      case @status
      when 0 # new song play
        if @world.video?
          @world.song_task = ThreadPoolManager.schedule_general(SongTask.new(@tomb, @world, 0), 1000)
        elsif @world.frintezza? && @world.frintezza.alive?
          if @world.frintezza.script_value != 1
            rnd = Rnd.rand(100)
            FRINTEZZA_SONG_LIST.each do |element|
              if rnd < element.chance
                @world.on_song = element
                @tomb.broadcast_packet(@world, ExShowScreenMessage.new(2, -1, 2, 0, 0, 0, 0, true, 4000, false, nil, element.song_name, nil))
                @tomb.broadcast_packet(@world, MagicSkillUse.new(@world.frintezza, @world.frintezza, element.skill.skill_id, element.skill.skill_lvl, element.skill.skill.hit_time, 0))
                @world.song_effect_task = ThreadPoolManager.schedule_general(SongTask.new(@tomb, @world, 1), element.skill.skill.hit_time - 10000)
                @world.song_task = ThreadPoolManager.schedule_general(SongTask.new(@tomb, @world, 0), element.skill.skill.hit_time)
                break
              end
            end
          else
            ThreadPoolManager.schedule_general(SoulBreakingArrow.new(@world.frintezza), 35000)
          end
        end
      when 1 # Frintezza song effect
        @world.song_effect_task = nil
        unless skill = @world.on_song.effect_skill.skill?
          return
        end

        if @world.frintezza? && @world.frintezza.alive? && @world.active_scarlet? && @world.active_scarlet.alive?
          targets = [] of L2Object
          if skill.has_effect_type?(EffectType::STUN) || skill.debuff?
            @world.allowed.each do |l2id|
              pc = L2World.get_player(l2id)
              if pc && pc.online? && pc.instance_id == @world.instance_id
                if pc.alive?
                  targets << pc
                end
                if (smn = pc.summon) && smn.alive?
                  targets << smn
                end
              end
            end
          else
            targets << @world.active_scarlet
          end
          unless targets.empty?
            @world.frintezza.do_cast(skill, targets.first.as(L2Character), targets)
          end
        end
      when 2 # finish morph
        @world.active_scarlet.r_hand_id = SECOND_SCARLET_WEAPON
        @world.active_scarlet.invul = false
      else
        # automatically added
      end

    end
  end

  private struct IntroTask
    initializer tomb : FinalEmperialTomb, world : FETWorld, status : Int32

    def call
      case @status
      when 0
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 1), 27000)
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 2), 30000)
        @tomb.broadcast_packet(@world, Earthquake.new(-87784, -155083, -9087, 45, 27))
      when 1
        FIRST_ROOM_DOORS.each do |door_id|
          @tomb.close_door(door_id, @world.instance_id)
        end
        FIRST_ROUTE_DOORS.each do |door_id|
          @tomb.close_door(door_id, @world.instance_id)
        end
        SECOND_ROOM_DOORS.each do |door_id|
          @tomb.close_door(door_id, @world.instance_id)
        end
        SECOND_ROUTE_DOORS.each do |door_id|
          @tomb.close_door(door_id, @world.instance_id)
        end
        @tomb.add_spawn(29061, -87904, -141296, -9168, 0, false, 0, false, @world.instance_id)
      when 2
        @world.frintezza_dummy = @tomb.add_spawn(29052, -87784, -155083, -9087, 16048, false, 0, false, @world.instance_id)
        @world.frintezza_dummy.invul = true
        @world.frintezza_dummy.immobilized = true

        @world.overhead_dummy = @tomb.add_spawn(29052, -87784, -153298, -9175, 16384, false, 0, false, @world.instance_id)
        @world.overhead_dummy.invul = true
        @world.overhead_dummy.immobilized = true
        @world.overhead_dummy.collision_height = 600
        @tomb.broadcast_packet(@world, NpcInfo.new(@world.overhead_dummy, nil))

        @world.portrait_dummy1 = @tomb.add_spawn(29052, -89566, -153168, -9165, 16048, false, 0, false, @world.instance_id)
        @world.portrait_dummy1.immobilized = true
        @world.portrait_dummy1.invul = true

        @world.portrait_dummy3 = @tomb.add_spawn(29052, -86004, -153168, -9165, 16048, false, 0, false, @world.instance_id)
        @world.portrait_dummy3.immobilized = true
        @world.portrait_dummy3.invul = true

        @world.scarlet_dummy = @tomb.add_spawn(29053, -87784, -153298, -9175, 16384, false, 0, false, @world.instance_id)
        @world.scarlet_dummy.invul = true
        @world.scarlet_dummy.immobilized = true

        stop_pc
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 3), 1000)
      when 3
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.overhead_dummy, 0, 75, -89, 0, 100, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.overhead_dummy, 0, 75, -89, 0, 100, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.overhead_dummy, 300, 90, -10, 6500, 7000, 0, 0, 1, 0, 0))

        @world.frintezza = @tomb.add_spawn(FRINTEZZA, -87780, -155086, -9080, 16384, false, 0, false, @world.instance_id).as(L2GrandBossInstance)
        @world.frintezza.immobilized = true
        @world.frintezza.invul = true
        @world.frintezza.disable_all_skills
        @tomb.update_known_list(@world, @world.frintezza)

        PORTRAIT_SPAWNS.each do |element|
          demon = @tomb.add_spawn(element[0] + 2, element[5], element[6], element[7], element[8], false, 0, false, @world.instance_id).as(L2MonsterInstance)
          demon.immobilized = true
          demon.disable_all_skills
          @tomb.update_known_list(@world, demon)
          @world.demons << demon
        end
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 4), 6500)
      when 4
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza_dummy, 1800, 90, 8, 6500, 7000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 5), 900)
      when 5
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza_dummy, 140, 90, 10, 2500, 4500, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 6), 4000)
      when 6
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 40, 75, -10, 0, 1000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 40, 75, -10, 0, 12000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 7), 1350)
      when 7
        @tomb.broadcast_packet(@world, SocialAction.new(@world.frintezza.l2id, 2))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 8), 7000)
      when 8
        @world.frintezza_dummy.delete_me
        @world.frintezza_dummy = nil
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 9), 1000)
      when 9
        @tomb.broadcast_packet(@world, SocialAction.new(@world.demons[1].l2id, 1))
        @tomb.broadcast_packet(@world, SocialAction.new(@world.demons[2].l2id, 1))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 10), 400)
      when 10
        @tomb.broadcast_packet(@world, SocialAction.new(@world.demons[0].l2id, 1))
        @tomb.broadcast_packet(@world, SocialAction.new(@world.demons[3].l2id, 1))
        send_packet_x(SpecialCamera.new(@world.portrait_dummy1, 1000, 118, 0, 0, 1000, 0, 0, 1, 0, 0), SpecialCamera.new(@world.portrait_dummy3, 1000, 62, 0, 0, 1000, 0, 0, 1, 0, 0), -87784)
        send_packet_x(SpecialCamera.new(@world.portrait_dummy1, 1000, 118, 0, 0, 10000, 0, 0, 1, 0, 0), SpecialCamera.new(@world.portrait_dummy3, 1000, 62, 0, 0, 10000, 0, 0, 1, 0, 0), -87784)
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 11), 2000)
      when 11
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 240, 90, 0, 0, 1000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 240, 90, 25, 5500, 10000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SocialAction.new(@world.frintezza.l2id, 3))
        @world.portrait_dummy1.delete_me
        @world.portrait_dummy3.delete_me
        @world.portrait_dummy1 = nil
        @world.portrait_dummy3 = nil
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 12), 4500)
      when 12
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 100, 195, 35, 0, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 13), 700)
      when 13
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 100, 195, 35, 0, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 14), 1300)
      when 14
        @tomb.broadcast_packet(@world, ExShowScreenMessage.new(NpcString::MOURNFUL_CHORALE_PRELUDE, 2, 5000))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 120, 180, 45, 1500, 10000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, MagicSkillUse.new(@world.frintezza, @world.frintezza, 5006, 1, 34000, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 15), 1500)
      when 15
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 520, 135, 45, 8000, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 16), 7500)
      when 16
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 1500, 110, 25, 10000, 13000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 17), 9500)
      when 17
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.overhead_dummy, 930, 160, -20, 0, 1000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.overhead_dummy, 600, 180, -25, 0, 10000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, MagicSkillUse.new(@world.scarlet_dummy, @world.overhead_dummy, 5004, 1, 5800, 0))

        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 18), 5000)
      when 18
        @world.active_scarlet = @tomb.add_spawn(29046, -87789, -153295, -9176, 16384, false, 0, false, @world.instance_id).as(L2GrandBossInstance)
        @world.active_scarlet.r_hand_id = FIRST_SCARLET_WEAPON
        @world.active_scarlet.invul = true
        @world.active_scarlet.immobilized = true
        @world.active_scarlet.disable_all_skills
        @tomb.update_known_list(@world, @world.active_scarlet)
        @tomb.broadcast_packet(@world, SocialAction.new(@world.active_scarlet.l2id, 3))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.scarlet_dummy, 800, 180, 10, 1000, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 19), 2100)
      when 19
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 300, 60, 8, 0, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 20), 2000)
      when 20
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 500, 90, 10, 3000, 5000, 0, 0, 1, 0, 0))
        @world.song_task = ThreadPoolManager.schedule_general(SongTask.new(@tomb, @world, 0), 100)
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 21), 3000)
      when 21
        PORTRAIT_SPAWNS.size.times do |i|
          portrait = @tomb.add_spawn(PORTRAIT_SPAWNS[i][0], PORTRAIT_SPAWNS[i][1], PORTRAIT_SPAWNS[i][2], PORTRAIT_SPAWNS[i][3], PORTRAIT_SPAWNS[i][4], false, 0, false, @world.instance_id).as(L2MonsterInstance)
          @tomb.update_known_list(@world, portrait)
          @world.portraits[portrait] = i
        end

        @world.overhead_dummy.delete_me
        @world.scarlet_dummy.delete_me
        @world.overhead_dummy = nil
        @world.scarlet_dummy = nil

        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 22), 2000)
      when 22
        @world.demons.each do |demon|
          demon.immobilized = false
          demon.enable_all_skills
        end
        @world.active_scarlet.invul = false
        @world.active_scarlet.immobilized = false
        @world.active_scarlet.enable_all_skills
        @world.active_scarlet.set_running
        @world.active_scarlet.do_cast(INTRO_SKILL)
        @world.frintezza.enable_all_skills
        @world.frintezza.disable_core_ai(true)
        @world.frintezza.mortal = false
        start_pc

        ThreadPoolManager.schedule_general(DemonSpawnTask.new(@tomb, @world), TIME_BETWEEN_DEMON_SPAWNS)
      when 23
        @tomb.broadcast_packet(@world, SocialAction.new(@world.frintezza.l2id, 4))
      when 24
        stop_pc
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 250, 120, 15, 0, 1000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 250, 120, 15, 0, 10000, 0, 0, 1, 0, 0))
        @world.active_scarlet.abort_attack
        @world.active_scarlet.abort_cast
        @world.active_scarlet.invul = true
        @world.active_scarlet.immobilized = true
        @world.active_scarlet.disable_all_skills
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 25), 7000)
      when 25
        @tomb.broadcast_packet(@world, MagicSkillUse.new(@world.frintezza, @world.frintezza, 5006, 1, 34000, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 500, 70, 15, 3000, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 26), 3000)
      when 26
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 2500, 90, 12, 6000, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 27), 3000)
      when 27
        @world.scarlet_x = @world.active_scarlet.x
        @world.scarlet_y = @world.active_scarlet.y
        @world.scarlet_z = @world.active_scarlet.z
        @world.scarlet_h = @world.active_scarlet.heading
        if @world.scarlet_h < 32768
          @world.scarlet_a = (180 - (@world.scarlet_h / 182.044444444).to_i).abs
        else
          @world.scarlet_a = (540 - (@world.scarlet_h / 182.044444444).to_i).abs
        end
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 250, @world.scarlet_a, 12, 0, 1000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 250, @world.scarlet_a, 12, 0, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 28), 500)
      when 28
        @world.active_scarlet.do_die(@world.active_scarlet)
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 450, @world.scarlet_a, 14, 8000, 8000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 29), 6250)
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 30), 7200)
      when 29
        @world.active_scarlet.delete_me
        @world.active_scarlet = nil
      when 30
        @world.active_scarlet = @tomb.add_spawn(SCARLET2, @world.scarlet_x, @world.scarlet_y, @world.scarlet_z, @world.scarlet_h, false, 0, false, @world.instance_id).as(L2GrandBossInstance)
        @world.active_scarlet.invul = true
        @world.active_scarlet.immobilized = true
        @world.active_scarlet.disable_all_skills
        @tomb.update_known_list(@world, @world.active_scarlet)

        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 450, @world.scarlet_a, 12, 500, 14000, 0, 0, 1, 0, 0))

        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 31), 8100)
      when 31
        @tomb.broadcast_packet(@world, SocialAction.new(@world.active_scarlet.l2id, 2))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 32), 9000)
      when 32
        start_pc
        @world.active_scarlet.invul = false
        @world.active_scarlet.immobilized = false
        @world.active_scarlet.enable_all_skills
        @world.video = false
      when 33
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 300, @world.scarlet_a - 180, 5, 0, 7000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.active_scarlet, 200, @world.scarlet_a, 85, 4000, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 34), 7400)
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 35), 7500)
      when 34
        @world.frintezza.do_die(@world.frintezza)
      when 35
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 100, 120, 5, 0, 7000, 0, 0, 1, 0, 0))
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 100, 90, 5, 5000, 15000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 36), 7000)
      when 36
        @tomb.broadcast_packet(@world, SpecialCamera.new(@world.frintezza, 900, 90, 25, 7000, 10000, 0, 0, 1, 0, 0))
        ThreadPoolManager.schedule_general(IntroTask.new(@tomb, @world, 37), 9000)
      when 37
        @tomb.control_status(@world)
        @world.video = false
        start_pc
      else
        # automatically added
      end

    end

    private def stop_pc
      @world.allowed.each do |l2id|
        pc = L2World.get_player(l2id)
        if pc && pc.online? && pc.instance_id == @world.instance_id
          pc.abort_attack
          pc.abort_cast
          pc.disable_all_skills
          pc.target = nil
          pc.stop_move(nil)
          pc.immobilized = true
          pc.set_intention(AI::IDLE)
        end
      end
    end

    private def start_pc
      @world.allowed.each do |l2id|
        pc = L2World.get_player(l2id)
        if pc && pc.online? && pc.instance_id == @world.instance_id
          pc.enable_all_skills
          pc.immobilized = false
        end
      end
    end

    private def send_packet_x(packet1, packet2, x)
      @world.allowed.each do |l2id|
        pc = L2World.get_player(l2id)
        if pc && pc.online? && pc.instance_id == @world.instance_id
          if pc.x < x
            pc.send_packet(packet1)
          else
            pc.send_packet(packet2)
          end
        end
      end
    end
  end

  private struct StatusTask
    initializer tomb : FinalEmperialTomb, world : FETWorld, status : Int32

    def call
      if InstanceManager.get_world(@world.instance_id) != @world
        return
      end
      case @status
      when 0
        ThreadPoolManager.schedule_general(StatusTask.new(@tomb, @world, 1), 2000)
        FIRST_ROOM_DOORS.each do |door_id|
          @tomb.open_door(door_id, @world.instance_id)
        end
      when 1
        add_aggro_to_mobs
      when 2
        ThreadPoolManager.schedule_general(StatusTask.new(@tomb, @world, 3), 100)
        SECOND_ROOM_DOORS.each do |door_id|
          @tomb.open_door(door_id, @world.instance_id)
        end
      when 3
        add_aggro_to_mobs
      when 4
        @tomb.control_status(@world)
      else
        # automatically added
      end

    end

    private def add_aggro_to_mobs
      target = L2World.get_player(@world.allowed.sample(random: Rnd))
      if target.nil? || (target.instance_id != @world.instance_id || target.dead? || target.fake_death?)
        @world.allowed.each do |l2id|
          target = L2World.get_player(l2id)
          if target && target.instance_id == @world.instance_id && target.alive? && !target.fake_death?
            break
          end
          target = nil
        end
      end
      @world.npc_list.each do |mob|
        mob.set_running
        if target
          mob.as(L2MonsterInstance).add_damage_hate(target, 0, 500)
          mob.set_intention(AI::ATTACK, target)
        else
          mob.set_intention(AI::MOVE_TO, MOVE_TO_CENTER)
        end
      end
    end
  end

  def broadcast_packet(world, packet)
    world.allowed.each do |l2id|
      pc = L2World.get_player(l2id)
      if pc && pc.online? && pc.instance_id == world.instance_id
        pc.send_packet(packet)
      end
    end
  end

  def update_known_list(world, npc)
    npc_known_players = npc.known_list.known_players
    world.allowed.each do |l2id|
      pc = L2World.get_player(l2id)
      if pc && pc.online? && pc.instance_id == world.instance_id
        npc_known_players[pc.l2id] = pc
      end
    end
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(FETWorld)
      if npc.id == SCARLET1 && world.status == 3 && npc.hp_percent < 80
        control_status(world)
      elsif npc.id == SCARLET1 && world.status == 4 && npc.hp_percent < 20
        control_status(world)
      end
      if skill
        # When Dewdrop of Destruction is used on Portraits they suicide.
        if PORTRAITS.includes?(npc.id) && skill.id == DEWDROP_OF_DESTRUCTION_SKILL_ID
          npc.do_die(attacker)
        elsif npc.id == FRINTEZZA && skill.id == SOUL_BREAKING_ARROW_SKILL_ID
          npc.script_value = 1
          npc.target = nil
          npc.set_intention(AI::IDLE)
        end
      end
    end

    nil
  end

  def on_spell_finished(npc, player, skill)
    if skill.suicide_attack?
      return on_kill(npc, nil, false)
    end

    super
  end

  def on_kill(npc, pc, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(FETWorld)
      if npc.id == HALL_ALARM
        ThreadPoolManager.schedule_general(StatusTask.new(self, world, 0), 2000)
        debug "Hall alarm is disabled and doors will open."
      elsif npc.id == DARK_CHOIR_PLAYER
        world.dark_choir_player_count -= 1
        if world.dark_choir_player_count < 1
          ThreadPoolManager.schedule_general(StatusTask.new(self, world, 2), 2000)
          debug "All Dark Choir Players are killed and doors will open."
        end
      elsif npc.id == SCARLET2
        control_status(world)
      elsif world.status <= 2
        if npc.id == HALL_KEEPER_CAPTAIN && Rnd.rand(100) < 5
          npc.drop_item(pc.not_nil!, DEWDROP_OF_DESTRUCTION_ITEM_ID, 1)
        end

        if check_kill_progress(npc, world)
          control_status(world)
        end
      elsif world.demons.includes?(npc)
        world.demons.delete(npc)
      elsif world.portraits.has_key?(npc)
        world.portraits.delete(npc)
      end
    end

    ""
  end

  def on_talk(npc, pc)
    get_quest_state!(pc)
    if npc.id == GUIDE
      enter_instance(pc, FETWorld.new, "FinalEmperialTomb.xml", TEMPLATE_ID)
    elsif npc.id == CUBE
      x = -87534 + Rnd.rand(500)
      y = -153048 + Rnd.rand(500)
      pc.tele_to_location(x, y, -9165)
      return
    end

    ""
  end
end