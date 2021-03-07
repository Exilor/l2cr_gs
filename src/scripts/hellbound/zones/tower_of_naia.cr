class Scripts::TowerOfNaia < AbstractNpcAI
  # Challenge states
  private STATE_SPORE_CHALLENGE_IN_PROGRESS = 1
  private STATE_SPORE_CHALLENGE_SUCCESSFULL = 2
  private STATE_SPORE_IDLE_TOO_LONG = 3

  # Some constants
  private SELF_DESPAWN_LIMIT = 600 # Challenge discontinues after 600 self-despawns by timer
  private ELEMENT_INDEX_LIMIT = 120 # Epidos spawns when index reaches 120 points

  # Skill
  private OVERFLOW = SkillHolder.new(5527)

  private LOCK = 18491
  private CONTROLLER = 18492
  private ROOM_MANAGER_FIRST = 18494
  private ROOM_MANAGER_LAST = 18505
  private MUTATED_ELPY = 25604
  private SPORE_BASIC = 25613
  private SPORE_FIRE = 25605
  private SPORE_WATER = 25606
  private SPORE_WIND = 25607
  private SPORE_EARTH = 25608
  private DWARVEN_GHOST = 32370
  private EPIDOSES = {
    25610,
    25609,
    25612,
    25611
  } # Order is important!
  private TOWER_MONSTERS = {
    18490,
    22393,
    22394,
    22395,
    22411,
    22412,
    22413,
    22439,
    22440,
    22441,
    22442
  }
  private ELEMENTS = {
    25605,
    25606,
    25607,
    25608
  }
  private OPPOSITE_ELEMENTS = {
    25606,
    25605,
    25608,
    25607
  }
  private ELEMENTS_NAME = {
    "Fire",
    "Water",
    "Wind",
    "Earth"
  }
  private SPORES_MOVE_POINTS = {
    {-46080, 246368, -14183},
    {-44816, 246368, -14183},
    {-44224, 247440, -14184},
    {-44896, 248464, -14183},
    {-46064, 248544, -14183},
    {-46720, 247424, -14183},
  }
  private SPORES_MERGE_POSITION = {
    {-45488, 246768, -14183},
    {-44767, 247419, -14183},
    {-46207, 247417, -14183},
    {-45462, 248174, -14183},
  }
  private SPORES_NPCSTRINGS = {
    NpcString::ITS_S1,
    NpcString::S1_IS_STRONG,
    NpcString::ITS_ALWAYS_S1,
    NpcString::S1_WONT_DO
  }

  private DOORS = {
    # Format: entrance_door, exit_door
    18494 => {18250001, 18250002},
    18495 => {18250003, 18250004},
    18496 => {18250005, 18250006},
    18497 => {18250007, 18250008},
    18498 => {18250009, 18250010},
    18499 => {18250011, 18250101},
    18500 => {18250013, 18250014},
    18501 => {18250015, 18250102},
    18502 => {18250017, 18250018},
    18503 => {18250019, 18250103},
    18504 => {18250021, 18250022},
    18505 => {18250023, 18250024}
  }
  private ZONES = {
    18494 => 200020,
    18495 => 200021,
    18496 => 200022,
    18497 => 200023,
    18498 => 200024,
    18499 => 200025,
    18500 => 200026,
    18501 => 200027,
    18502 => 200028,
    18503 => 200029,
    18504 => 200030,
    18505 => 200031
  }

  private record SpawnInfo, npc_id : Int32, x : Int32, y : Int32, z : Int32,
    heading : Int32

  private SPAWNS = {
    18494 => [
      SpawnInfo.new(22393, -46371, 246400, -9120, 0),
      SpawnInfo.new(22394, -46435, 245830, -9120, 0),
      SpawnInfo.new(22394, -46536, 246275, -9120, 0),
      SpawnInfo.new(22393, -46239, 245996, -9120, 0),
      SpawnInfo.new(22394, -46229, 246347, -9120, 0),
      SpawnInfo.new(22394, -46019, 246198, -9120, 0)
    ],
    18495 => [
      SpawnInfo.new(22439, -48146, 249597, -9124, -16280),
      SpawnInfo.new(22439, -48144, 248711, -9124, 16368),
      SpawnInfo.new(22439, -48704, 249597, -9104, -16380),
      SpawnInfo.new(22439, -49219, 249596, -9104, -16400),
      SpawnInfo.new(22439, -49715, 249601, -9104, -16360),
      SpawnInfo.new(22439, -49714, 248696, -9104, 15932),
      SpawnInfo.new(22439, -49225, 248710, -9104, 16512),
      SpawnInfo.new(22439, -48705, 248708, -9104, 16576)
    ],
    18496 => [
      SpawnInfo.new(22441, -51176, 246055, -9984, 0),
      SpawnInfo.new(22441, -51699, 246190, -9984, 0),
      SpawnInfo.new(22442, -52060, 245956, -9984, 0),
      SpawnInfo.new(22442, -51565, 246433, -9984, 0)
    ],
    18497 => [
      SpawnInfo.new(22440, -49754, 243866, -9968, -16328),
      SpawnInfo.new(22440, -49754, 242940, -9968, 16336),
      SpawnInfo.new(22440, -48733, 243858, -9968, -16208),
      SpawnInfo.new(22440, -48745, 242936, -9968, 16320),
      SpawnInfo.new(22440, -49264, 242946, -9968, 16312),
      SpawnInfo.new(22440, -49268, 243869, -9968, -16448),
      SpawnInfo.new(22440, -48186, 242934, -9968, 16576),
      SpawnInfo.new(22440, -48185, 243855, -9968, -16448)
    ],
    18498 => [
      SpawnInfo.new(22411, -46355, 246375, -9984, 0),
      SpawnInfo.new(22411, -46167, 246160, -9984, 0),
      SpawnInfo.new(22393, -45952, 245748, -9984, 0),
      SpawnInfo.new(22394, -46428, 246254, -9984, 0),
      SpawnInfo.new(22393, -46490, 245871, -9984, 0),
      SpawnInfo.new(22394, -45877, 246309, -9984, 0)
    ],
    18499 => [
      SpawnInfo.new(22395, -48730, 248067, -9984, 0),
      SpawnInfo.new(22395, -49112, 248250, -9984, 0)
    ],
    18500 => [
      SpawnInfo.new(22393, -51954, 246475, -10848, 0),
      SpawnInfo.new(22394, -51421, 246512, -10848, 0),
      SpawnInfo.new(22394, -51404, 245951, -10848, 0),
      SpawnInfo.new(22393, -51913, 246206, -10848, 0),
      SpawnInfo.new(22394, -51663, 245979, -10848, 0),
      SpawnInfo.new(22394, -51969, 245809, -10848, 0),
      SpawnInfo.new(22412, -51259, 246357, -10848, 0)
    ],
    18501 => [
      SpawnInfo.new(22395, -48856, 243949, -10848, 0),
      SpawnInfo.new(22395, -49144, 244190, -10848, 0)
    ],
    18502 => [
      SpawnInfo.new(22441, -46471, 246135, -11704, 0),
      SpawnInfo.new(22441, -46449, 245997, -11704, 0),
      SpawnInfo.new(22441, -46235, 246187, -11704, 0),
      SpawnInfo.new(22441, -46513, 246326, -11704, 0),
      SpawnInfo.new(22441, -45889, 246313, -11704, 0)
    ],
    18503 => [
      SpawnInfo.new(22395, -49067, 248050, -11712, 0),
      SpawnInfo.new(22395, -48957, 248223, -11712, 0)
    ],
    18504 => [
      SpawnInfo.new(22413, -51748, 246138, -12568, 0),
      SpawnInfo.new(22413, -51279, 246200, -12568, 0),
      SpawnInfo.new(22413, -51787, 246594, -12568, 0),
      SpawnInfo.new(22413, -51892, 246544, -12568, 0),
      SpawnInfo.new(22413, -51500, 245781, -12568, 0),
      SpawnInfo.new(22413, -51941, 246045, -12568, 0)
    ],
    18505 => [
      SpawnInfo.new(18490, -48238, 243347, -13376, 0),
      SpawnInfo.new(18490, -48462, 244022, -13376, 0),
      SpawnInfo.new(18490, -48050, 244045, -13376, 0),
      SpawnInfo.new(18490, -48229, 243823, -13376, 0),
      SpawnInfo.new(18490, -47871, 243208, -13376, 0),
      SpawnInfo.new(18490, -48255, 243528, -13376, 0),
      SpawnInfo.new(18490, -48461, 243780, -13376, 0),
      SpawnInfo.new(18490, -47983, 243197, -13376, 0),
      SpawnInfo.new(18490, -47841, 243819, -13376, 0),
      SpawnInfo.new(18490, -48646, 243764, -13376, 0),
      SpawnInfo.new(18490, -47806, 243850, -13376, 0),
      SpawnInfo.new(18490, -48456, 243447, -13376, 0)
    ]
  }

  private INDEX_COUNT = Slice.new(2, 0)
  private ACTIVE_ROOMS = {} of Int32 => Bool
  private NPC_SPAWNS = Concurrent::Map(Int32, Concurrent::Array(L2Npc)).new
  private SPORE_SPAWNS = Concurrent::Set(L2Npc).new

  @counter = 90
  @despawned_spores_count = Atomic(Int32).new(0)
  @challenge_state = 0
  @win_index = 0
  @controller : L2Npc?

  def initialize
    super(self.class.simple_name, "hellbound/AI/Zones")

    add_first_talk_id(CONTROLLER)
    add_start_npc(CONTROLLER, DWARVEN_GHOST)
    add_talk_id(CONTROLLER, DWARVEN_GHOST)
    add_attack_id(LOCK)
    add_kill_id(LOCK, MUTATED_ELPY, SPORE_BASIC)
    add_spawn_id(MUTATED_ELPY, SPORE_BASIC)

    SPORE_FIRE.upto(SPORE_EARTH) do |npc_id|
      add_kill_id(npc_id)
      add_spawn_id(npc_id)
    end

    ROOM_MANAGER_FIRST.upto(ROOM_MANAGER_LAST) do |npc_id|
      add_first_talk_id(npc_id)
      add_talk_id(npc_id)
      add_start_npc(npc_id)
      init_room(npc_id)
    end

    TOWER_MONSTERS.each do |npc_id|
      add_kill_id(npc_id)
    end

    @lock = add_spawn(LOCK, 16409, 244438, 11620, -1048, false, 0, false).as(L2MonsterInstance)
    @controller = add_spawn(CONTROLLER, 16608, 244420, 11620, 31264, false, 0, false)
    init_spore_challenge
    spawn_elpy
  end

  def on_first_talk(npc, player)
    npc_id = npc.id

    if npc_id == CONTROLLER
      unless @lock
        return "18492-02.htm"
      end
      return "18492-01.htm"
    elsif npc_id.between?(ROOM_MANAGER_FIRST, ROOM_MANAGER_LAST)
      if ACTIVE_ROOMS.has_key?(npc_id) && !ACTIVE_ROOMS[npc_id]
        unless player.in_party?
          player.send_packet(SystemMessageId::CAN_OPERATE_MACHINE_WHEN_IN_PARTY)
          return
        end
        return "manager.htm"
      end
    end

    super
  end

  def on_adv_event(event, npc, player)
    html = event

    # Timer. Spawns Naia Lock
    if event.casecmp?("spawn_lock")
      html = nil
      @lock = add_spawn(LOCK, 16409, 244438, 11620, -1048, false, 0, false).as(L2MonsterInstance)
      @counter = 90
    # Timer. Depending of @challenge_state despans all spawned spores, or spores, reached assembly point
    elsif event.casecmp?("despawn_total")
      # Spores is not attacked too long - despawn them all, reinit values
      if @challenge_state == STATE_SPORE_IDLE_TOO_LONG
        remove_spores
        init_spore_challenge
      # Spores are moving to assembly point. Despawn all reached, check for reached spores count.
      elsif @challenge_state == STATE_SPORE_CHALLENGE_SUCCESSFULL && @win_index >= 0
        # Requirements are met, despawn all spores, spawn Epidos
        if @despawned_spores_count.get >= 10 || SPORE_SPAWNS.empty?
          remove_spores
          @despawned_spores_count.set(0)
          coords = SPORES_MERGE_POSITION[@win_index]
          add_spawn(EPIDOSES[@win_index], *coords, 0, false, 0, false)
          init_spore_challenge
        # Requirements aren't met, despawn reached spores
        else
          SPORE_SPAWNS.each do |spore|
            if spore && spore.alive?
              if spore.x == spore.spawn.x && spore.y == spore.spawn.y
                spore.delete_me
                SPORE_SPAWNS.delete(spore)
                @despawned_spores_count.add(1)
              end
            end
          end
          start_quest_timer("despawn_total", 3000, nil, nil)
        end
      end
    end

    unless npc
      return
    end

    npc_id = npc.id

    if event.casecmp?("despawn_spore") && npc.alive? && @challenge_state == STATE_SPORE_CHALLENGE_IN_PROGRESS
      html = nil

      SPORE_SPAWNS.delete(npc)
      npc.delete_me

      if npc_id == SPORE_BASIC
        spawn_random_spore
        spawn_random_spore
      elsif npc_id >= SPORE_FIRE && npc_id <= SPORE_EARTH
        @despawned_spores_count.add(1)

        if @despawned_spores_count.get < SELF_DESPAWN_LIMIT
          spawn_opposite_spore(npc_id)
        else
          @challenge_state = STATE_SPORE_IDLE_TOO_LONG
          start_quest_timer("despawn_total", 60000, nil, nil)
        end
      end
    elsif event.casecmp?("18492-05.htm")
      lock = @lock
      if lock.nil? || lock.current_hp > lock.max_hp / 10
        html = nil
        if lock
          lock.delete_me
          @lock = nil
        end
        cancel_quest_timers("spawn_lock")
        start_quest_timer("spawn_lock", 300000, nil, nil)
        npc.target = player
        npc.do_cast(OVERFLOW)
      end
    elsif event.casecmp?("teleport") && (lock = @lock)
      html = nil
      player = player.not_nil!
      if party = player.party
        if Util.in_range?(3000, party.leader, npc, true)
          party.members.each do |m|
            if Util.in_range?(2000, m, npc, true)
              m.tele_to_location(-47271, 246098, -9120, true)
            end
          end
          lock.delete_me
          @lock = nil
          cancel_quest_timers("spawn_lock")
          start_quest_timer("spawn_lock", 1200000, nil, nil)
        else
          npc.target = player
          npc.do_cast(OVERFLOW)
        end
      else
        player.tele_to_location(-47271, 246098, -9120)
        lock.delete_me
        @lock = nil
        cancel_quest_timers("spawn_lock")
        start_quest_timer("spawn_lock", 1200000, nil, nil)
      end
    elsif event.casecmp?("go") && ACTIVE_ROOMS.has_key?(npc_id) && !ACTIVE_ROOMS[npc_id]
      html = nil
      player = player.not_nil!
      if party = player.party
        remove_foreigners(npc_id, party)
        start_room(npc_id)
        ThreadPoolManager.schedule_general(StopRoomTask.new(self, npc_id), 300000)
      else
        player.send_packet(SystemMessageId::CAN_OPERATE_MACHINE_WHEN_IN_PARTY)
      end
    end

    html
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    lock = @lock
    if lock && npc.l2id == lock.l2id
      rem_hp_per = ((npc.current_hp * 100) / npc.max_hp).to_i
      controller = @controller
      if rem_hp_per <= @counter && controller
        if @counter == 50
          MinionList.spawn_minion(lock, 18493)
        elsif @counter == 10
          MinionList.spawn_minion(lock, 18493)
          MinionList.spawn_minion(lock, 18493)
        end
        broadcast_npc_say(controller, Say2::NPC_ALL, NpcString::EMERGENCY_EMERGENCY_THE_OUTER_WALL_IS_WEAKENING_RAPIDLY)
        @counter -= 10
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    npc_id = npc.id

    if npc_id == LOCK
      @lock = nil
      cancel_quest_timers("spawn_lock")
      start_quest_timer("spawn_lock", 300_000, nil, nil)
    elsif TOWER_MONSTERS.bincludes?(npc_id)
      manager_id = 0

      ZoneManager.get_zones(npc.x, npc.y, npc.z) do |zone|
        ZONES.each_value do |id|
          if id == zone.id
            manager_id = id
            break
          end
          end
      end

      if manager_id > 0 && (spawned = NPC_SPAWNS[manager_id]?)
        spawned.delete_first(npc)
        if spawned.empty? && (door_list = DOORS[manager_id]?)
          DoorData.get_door!(door_list[1]).open_me
          NPC_SPAWNS.delete(manager_id)
        end
      end
    elsif npc_id == MUTATED_ELPY
      @challenge_state = STATE_SPORE_CHALLENGE_IN_PROGRESS
      mark_elpy_respawn
      DoorData.get_door!(18250025).close_me
      ZoneManager.get_zone_by_id(200100).not_nil!.enabled = true

      10.times do
        add_spawn(SPORE_BASIC, -45474, 247450, -13994, 49152, false, 0, false)
      end
    elsif npc_id == SPORE_BASIC && @challenge_state == STATE_SPORE_CHALLENGE_IN_PROGRESS
      SPORE_SPAWNS.delete(npc)
      spawn_random_spore
      spawn_random_spore
    elsif npc_id >= SPORE_FIRE && npc_id <= SPORE_EARTH && (@challenge_state == STATE_SPORE_CHALLENGE_IN_PROGRESS || @challenge_state == STATE_SPORE_CHALLENGE_SUCCESSFULL)
      SPORE_SPAWNS.delete(npc)

      if @challenge_state == STATE_SPORE_CHALLENGE_IN_PROGRESS
        @despawned_spores_count.sub(1)
        spore_group = get_spore_group(npc_id)

        if spore_group >= 0
          if npc_id == SPORE_FIRE || npc_id == SPORE_WIND
            INDEX_COUNT[spore_group] &+= 2
          else
            INDEX_COUNT[spore_group] &-= 2
          end

          if INDEX_COUNT[(spore_group - 1).abs] > 0
            INDEX_COUNT[(spore_group - 1).abs] &+= 1
          elsif INDEX_COUNT[(spore_group - 1).abs] < 0
            INDEX_COUNT[(spore_group - 1).abs] &+= 1
          end

          if INDEX_COUNT[spore_group].abs < ELEMENT_INDEX_LIMIT && INDEX_COUNT[spore_group].abs > 0 && INDEX_COUNT[spore_group] % 20 == 0 && Rnd.bool
            el = ELEMENTS_NAME[ELEMENTS.bsearch_index_of(npc_id) || 0]
            SPORE_SPAWNS.each do |spore|
              if spore && spore.alive? && spore.id == npc_id
                broadcast_npc_say(spore, Say2::NPC_ALL, SPORES_NPCSTRINGS.sample, el)
              end
            end
          end
          if INDEX_COUNT[spore_group].abs < ELEMENT_INDEX_LIMIT
            if ((INDEX_COUNT[spore_group] > 0 && (npc_id == SPORE_FIRE || npc_id == SPORE_WIND)) || (INDEX_COUNT[spore_group] <= 0 && (npc_id == SPORE_WATER || npc_id == SPORE_EARTH))) && Rnd.rand(1000) > 200
              spawn_opposite_spore(npc_id)
            else
              spawn_random_spore
            end
          else
          # index value was reached
            @challenge_state = STATE_SPORE_CHALLENGE_SUCCESSFULL
            @despawned_spores_count.set(0)
            @win_index = ELEMENTS.bsearch_index_of(npc_id) || 0
            coord = SPORES_MERGE_POSITION[@win_index]

            SPORE_SPAWNS.each do |spore|
              if spore.alive?
                move_to(spore, coord)
              end
            end

            start_quest_timer("despawn_total", 3000, nil, nil)
          end
        end
      end
    end

    super
  end

  def on_spawn(npc)
    npc_id = npc.id

    if npc_id == MUTATED_ELPY
      DoorData.get_door!(18250025).open_me
      ZoneManager.get_zone_by_id(200100).not_nil!.enabled = false
      ZoneManager.get_zone_by_id(200101).not_nil!.enabled = true
      ZoneManager.get_zone_by_id(200101).not_nil!.enabled = false
    elsif npc_id == SPORE_BASIC || npc_id.between?(SPORE_FIRE, SPORE_EARTH)
      if @challenge_state == STATE_SPORE_CHALLENGE_IN_PROGRESS
        SPORE_SPAWNS << npc
        npc.running = false
        coord = SPORES_MOVE_POINTS.sample(random: Rnd)
        npc.spawn.x = coord[0]
        npc.spawn.y = coord[1]
        npc.spawn.z = coord[2]
        npc.set_intention(AI::MOVE_TO, Location.new(*coord, 0))
        start_quest_timer("despawn_spore", 60000, npc, nil)
      end
    end

    super
  end

  private def get_spore_group(spore_id)
    case spore_id
    when SPORE_FIRE, SPORE_WATER
      0
    when SPORE_WIND, SPORE_EARTH
      1
    else
      -1
    end
  end

  protected def init_room(manager_id)
    remove_all_players(manager_id)
    ACTIVE_ROOMS[manager_id] = false

    if door_list = DOORS[manager_id]?
      DoorData.get_door!(door_list[0]).open_me
      DoorData.get_door!(door_list[1]).close_me
    end

    if tmp = NPC_SPAWNS[manager_id]?
      tmp.each do |npc|
        if npc && npc.alive?
          npc.delete_me
        end
      end
      tmp.clear
      SPAWNS.delete(manager_id)
    end
  end

  private def init_spore_challenge
    @despawned_spores_count.set(0)
    @challenge_state = 0
    @win_index = -1
    INDEX_COUNT[0] = 0
    INDEX_COUNT[1] = 0
    ZoneManager.get_zone_by_id(200100).not_nil!.enabled = false
    ZoneManager.get_zone_by_id(200101).not_nil!.enabled = false
    ZoneManager.get_zone_by_id(200101).not_nil!.enabled = true
  end

  private def mark_elpy_respawn
    respawn_time = (Rnd.rand(43200..216000) * 1000) + Time.ms
    GlobalVariablesManager.instance["elpy_respawn_time"] = respawn_time
  end

  private def move_to(npc, coords)
    time = 0
    if npc
      distance = npc.calculate_distance(*coords, true, false)
      heading = Util.calculate_heading_from(npc.x, npc.y, coords[0], coords[1])
      time = ((distance / npc.walk_speed) * 1000).to_i
      npc.running = false
      npc.disable_core_ai(true)
      npc.no_random_walk = true
      npc.set_intention(AI::MOVE_TO, Location.new(*coords, heading))
      npc.spawn.x = coords[0]
      npc.spawn.y = coords[1]
      npc.spawn.z = coords[2]
    end

    time == 0 ? 100 : time
  end

  private def spawn_elpy
    respawn_time = GlobalVariablesManager.instance.get_i64("elpy_respawn_time", 0)
    time = Time.ms
    if respawn_time <= time
      add_spawn(MUTATED_ELPY, -45474, 247450, -13994, 49152, false, 0, false)
    else
      task = -> do
        add_spawn(MUTATED_ELPY, -45474, 247450, -13994, 49152, false, 0, false)
      end
      ThreadPoolManager.schedule_general(task, respawn_time - time)
    end
  end

  private def spawn_random_spore
    add_spawn(Rnd.rand(SPORE_FIRE..SPORE_EARTH), -45474, 247450, -13994, 49152, false, 0, false)
  end

  private def spawn_opposite_spore(src_spore_id)
    if idx = ELEMENTS.bsearch_index_of(src_spore_id)
      add_spawn(OPPOSITE_ELEMENTS[idx], -45474, 247450, -13994, 49152, false, 0, false)
    end
  end

  private def start_room(manager_id)
    ACTIVE_ROOMS[manager_id] = true

    if door_list = DOORS[manager_id]?
      DoorData.get_door!(door_list[0]).close_me
    end

    if spawn_list = SPAWNS[manager_id]?
      spawned = Concurrent::Array(L2Npc).new
      spawn_list.each do |sp|
        spawned_npc = add_spawn(sp.npc_id, sp.x, sp.y, sp.z, sp.heading, false, 0, false)
        spawned << spawned_npc
      end
      unless spawned.empty?
        NPC_SPAWNS[manager_id] = spawned
      end
    end
  end

  private def remove_foreigners(manager_id, party)
    return unless party
    return unless tmp = ZONES[manager_id]?
    return unless zone = ZoneManager.get_zone_by_id(tmp)
    zone.each_player_inside do |pc|
      if party2 = pc.party
        if party2.leader_l2id != party.leader_l2id
          pc.tele_to_location(16110, 243841, 11616)
        end
      end
    end
  end

  private def remove_all_players(manager_id)
    return unless tmp = ZONES[manager_id]?
    return unless zone = ZoneManager.get_zone_by_id(tmp)
    zone.each_player_inside do |pc|
      pc.tele_to_location(16110, 243841, 11616)
    end
  end

  private def remove_spores
    SPORE_SPAWNS.each do |spore|
      if spore.alive?
        spore.delete_me
      end
    end
    SPORE_SPAWNS.clear
    cancel_quest_timers("despawn_spore")
  end

  private struct StopRoomTask
    initializer owner : TowerOfNaia, manager_id : Int32

    def call
      @owner.init_room(@manager_id)
    end
  end
end
