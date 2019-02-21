class DarkCloudMansion < AbstractInstance
  private class DMCWorld < InstanceWorld
    getter rooms = {} of Symbol => DMCRoom
  end

  private class DMCNpc
    property! npc : L2Npc?
    property? dead = false
    property! golem : L2Npc?
    property status : Int32 = 0
    property order : Int32 = 0
    property count : Int32 = 0
  end

  private class DMCRoom
    getter npc_list = [] of DMCNpc
    property counter : Int32 = 0
    property reset : Int32 = 0
    property found : Int32 = 0
    property order : Slice(Int32) = Slice(Int32).empty
  end

  # NPCs
  private YIYEN = 32282
  private SYM_FAITH = 32288 # Symbol of Faith
  private SYM_ADVERSITY = 32289 # Symbol of Adversity
  private SYM_ADVENTURE = 32290 # Symbol of Adventure
  private SYM_TRUTH = 32291 # Symbol of Truth
  private BSM = 32324 # Black Stone Monolith
  private SC = 22402 # Shadow Column
  # Mobs
  private CCG = {
    18369,
    18370
  } # Chromatic Crystal Golem
  private BM = {
    22272,
    22273,
    22274
  } # Beleth's Minions
  private HG = {
    22264,
    22264
  } # [22318,22319] #Hall Guards
  private BS = {
    18371,
    18372,
    18373,
    18374,
    18375,
    18376,
    18377
  } # Beleth's Samples
  private TOKILL = {
    18371,
    18372,
    18373,
    18374,
    18375,
    18376,
    18377,
    22318,
    22319,
    22272,
    22273,
    22274,
    18369,
    18370,
    22402,
    22264
  }

  # Items
  private CC = 9690 # Contaminated Crystal
  # Misc
  private TEMPLATE_ID = 9
  private D1 = 24230001 # Starting Room
  private D2 = 24230002 # First Room
  private D3 = 24230005 # Second Room
  private D4 = 24230003 # Third Room
  private D5 = 24230004 # Forth Room
  private D6 = 24230006 # Fifth Room
  private W1 = 24230007 # Wall 1
  # W2 = 24230008 # Wall 2
  # W3 = 24230009 # Wall 3
  # W4 = 24230010 # Wall 4
  # W5 = 24230011 # Wall 5
  # W6 = 24230012 # Wall 6
  # W7 = 24230013 # Wall 7

  private SPAWN_CHAT = {
    NpcString::IM_THE_REAL_ONE,
    NpcString::PICK_ME,
    NpcString::TRUST_ME,
    NpcString::NOT_THAT_DUDE_IM_THE_REAL_ONE,
    NpcString::DONT_BE_FOOLED_DONT_BE_FOOLED_IM_THE_REAL_ONE
  }
  private DECAY_CHAT = {
    NpcString::IM_THE_REAL_ONE_PHEW,
    NpcString::CANT_YOU_EVEN_FIND_OUT,
    NpcString::FIND_ME
  }
  private SUCCESS_CHAT = {
    NpcString::HUH_HOW_DID_YOU_KNOW_IT_WAS_ME,
    NpcString::EXCELLENT_CHOICE_TEEHEE,
    NpcString::YOUVE_DONE_WELL,
    NpcString::OH_VERY_SENSIBLE
  }
  private FAILED_CHAT = {
    NpcString::YOUVE_BEEN_FOOLED,
    NpcString::SORRY_BUT_IM_THE_FAKE_ONE
  }
  # Second room - random monolith order
  private MONOLITH_ORDER = {
    {1, 2, 3, 4, 5, 6},
    {6, 5, 4, 3, 2, 1},
    {4 ,5, 6, 3, 2, 1},
    {2, 6, 3, 5, 1, 4},
    {4, 1, 5, 6, 2, 3},
    {3, 5, 1, 6, 2, 4},
    {6, 1, 3, 4, 5, 2},
    {5, 6, 1, 2, 4, 3},
    {5, 2, 6, 3, 4, 1},
    {1, 5, 2, 6, 3, 4},
    {1, 2, 3, 6, 5, 4},
    {6, 4, 3, 1, 5, 2},
    {3, 5, 2, 4, 1, 6},
    {3, 2, 4, 5, 1, 6},
    {5, 4, 3, 1, 6, 2},
  }
  # Second room - golem spawn locatons - random
  private GOLEM_SPAWN = {
    {CCG[0], 148060, 181389},
    {CCG[1], 147910, 181173},
    {CCG[0], 147810, 181334},
    {CCG[1], 147713, 181179},
    {CCG[0], 147569, 181410},
    {CCG[1], 147810, 181517},
    {CCG[0], 147805, 181281},
  }

  # forth room - random shadow column
  private COLUMN_ROWS = {
    {1, 1, 0, 1, 0},
    {0, 1, 1, 0, 1},
    {1, 0, 1, 1, 0},
    {0, 1, 0, 1, 1},
    {1, 0, 1, 0, 1},
  }

  # Fifth room - beleth order
  private BELETHS = {
    {1, 0, 1, 0, 1, 0, 0},
    {0, 0, 1, 0, 1, 1, 0},
    {0, 0, 0, 1, 0, 1, 1},
    {1, 0, 1, 1, 0, 0, 0},
    {1, 1, 0, 0, 0, 1, 0},
    {0, 1, 0, 1, 0, 1, 0},
    {0, 0, 0, 1, 1, 1, 0},
    {1, 0, 1, 0, 0, 1, 0},
    {0, 1, 1, 0, 0, 0, 1},
  }

  @no_random_walk = true

  def initialize
    super(self.class.simple_name)

    add_first_talk_id(BSM, SYM_TRUTH)
    add_start_npc(YIYEN)
    add_talk_id(YIYEN, SYM_TRUTH)
    add_attack_id(SC)
    add_attack_id(BS)
    add_attack_id(CCG)
    add_kill_id(TOKILL)
  end

  private def check_conditions(player)
    if player.override_instance_conditions?
      debug "#{player} overrides instance conditions."
      return true
    end

    unless party = player.party?
      player.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end
    if party.leader != player
      player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end
    if party.size > 2
      player.send_packet(SystemMessageId::PARTY_EXCEEDED_THE_LIMIT_CANT_ENTER)
      return false
    end
    party.members.each do |m|
      if m.level < 78
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        player.send_packet(sm)
        return false
      end
      unless m.inside_radius?(player, 1000, true, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        player.send_packet(sm)
        return false
      end
    end

    return true
  end

  def on_enter_instance(player, world, first_entrance)
    if first_entrance
      run_start_room(world.as(DMCWorld))
      if party = player.party?
        party.members.each do |m|
          get_quest_state(m, true)
          world.add_allowed(m.l2id)
          teleport_player(m, Location.new(146534, 180464, -6117), world.instance_id)
        end
      end
    else
      teleport_player(player, Location.new(146534, 180464, -6117), world.instance_id)
    end
  end

  private def run_start_room(world)
    world.status = 0
    start_room = DMCRoom.new

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[0], 146817, 180335, -6117, 0, false, 0, false, world.instance_id)
    start_room.npc_list << this_npc
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[0], 146741, 180589, -6117, 0, false, 0, false, world.instance_id)
    start_room.npc_list << this_npc
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    world.rooms[:StartRoom] = start_room
  end

  private def spawn_hall(world)
    hall = DMCRoom.new
    world.rooms.delete(:Hall) # remove room instance to avoid adding mob every time

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[1], 147217, 180112, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[2], 147217, 180209, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[1], 148521, 180112, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[0], 148521, 180209, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[1], 148525, 180910, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[2], 148435, 180910, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[1], 147242, 180910, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BM[2], 147242, 180819, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    hall.npc_list << this_npc

    world.rooms[:Hall] = hall
  end

  private def run_hall(world)
    spawn_hall(world)
    world.status = 1
    open_door(D1, world.instance_id)
  end

  private def run_first_room(world)
    first_room = DMCRoom.new

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(HG[1], 147842, 179837, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    first_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(HG[0], 147711, 179708, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    first_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(HG[1], 147842, 179552, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    first_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(HG[0], 147964, 179708, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    first_room.npc_list << this_npc

    world.rooms[:FirstRoom] = first_room
    world.status = 2
    open_door(D2, world.instance_id)
  end

  private def run_hall_2(world)
    add_spawn(SYM_FAITH, 147818, 179643, -6117, 0, false, 0, false, world.instance_id)
    spawn_hall(world)
    world.status = 3
  end

  private def run_second_room(world)
    second_room = DMCRoom.new

    second_room.order = Slice(Int32).new(7)
    second_room.order[0] = 1

    i = Rnd.rand(MONOLITH_ORDER.size)

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BSM, 147800, 181150, -6117, 0, false, 0, false, world.instance_id)
    this_npc.order = MONOLITH_ORDER[i][0]
    second_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BSM, 147900, 181215, -6117, 0, false, 0, false, world.instance_id)
    this_npc.order = MONOLITH_ORDER[i][1]
    second_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BSM, 147900, 181345, -6117, 0, false, 0, false, world.instance_id)
    this_npc.order = MONOLITH_ORDER[i][2]
    second_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BSM, 147800, 181410, -6117, 0, false, 0, false, world.instance_id)
    this_npc.order = MONOLITH_ORDER[i][3]
    second_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BSM, 147700, 181345, -6117, 0, false, 0, false, world.instance_id)
    this_npc.order = MONOLITH_ORDER[i][4]
    second_room.npc_list << this_npc

    this_npc = DMCNpc.new
    this_npc.npc = add_spawn(BSM, 147700, 181215, -6117, 0, false, 0, false, world.instance_id)
    this_npc.order = MONOLITH_ORDER[i][5]
    second_room.npc_list << this_npc

    world.rooms[:SecondRoom] = second_room
    world.status = 4
    open_door(D3, world.instance_id)
  end

  private def run_hall3(world)
    add_spawn(SYM_ADVERSITY, 147808, 181281, -6117, 16383, false, 0, false, world.instance_id)
    spawn_hall(world)
    world.status = 5
  end

  private def run_third_room(world)
    third_room = DMCRoom.new
    this_npc = DMCNpc.new
    this_npc.dead = false
    this_npc.npc = add_spawn(BM[1], 148765, 180450, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[2], 148865, 180190, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[1], 148995, 180190, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[0], 149090, 180450, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[1], 148995, 180705, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[2], 148865, 180705, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    world.rooms[:ThirdRoom] = third_room
    world.status = 6
    open_door(D4, world.instance_id)
  end

  private def run_third_room2(world)
    add_spawn(SYM_ADVENTURE, 148910, 178397, -6117, 16383, false, 0, false, world.instance_id)
    third_room = DMCRoom.new
    this_npc = DMCNpc.new
    this_npc.dead = false
    this_npc.npc = add_spawn(BM[1], 148765, 180450, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[2], 148865, 180190, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[1], 148995, 180190, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[0], 149090, 180450, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[1], 148995, 180705, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    this_npc.npc = add_spawn(BM[2], 148865, 180705, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      this_npc.npc.no_rnd_walk = true
    end
    third_room.npc_list << this_npc
    world.rooms[:ThirdRoom2] = third_room
    world.status = 8
  end

  private def run_fourth_room(world)
    fourth_room = DMCRoom.new
    fourth_room.counter = 0
    templist = Slice.new(7) { COLUMN_ROWS.sample.to_slice }
    xx = 0


    x = 148660
    while x < 149285
      yy = 0
      y = 179280
      while y > 178405
        this_npc = DMCNpc.new
        this_npc.npc = add_spawn(SC, x, y, -6115, 16215, false, 0, false, world.instance_id)
        this_npc.status = templist[yy][xx]
        this_npc.order = yy
        if this_npc.status == 0
          this_npc.npc.invul = true
        end
        fourth_room.npc_list << this_npc

        y -= 125
        yy += 1
      end
      x += 125
      xx += 1
    end

    world.rooms[:FourthRoom] = fourth_room
    world.status = 7
    open_door(D5, world.instance_id)
  end

  private def run_fifth_room(world)
    spawn_fifth_room(world)
    world.status = 9
    open_door(D6, world.instance_id)
  end

  private def spawn_fifth_room(world)
    idx = 0
    temp = Slice.new(6, 0)
    fifth_room = DMCRoom.new

    temp = BELETHS.sample(Rnd)

    fifth_room.reset = 0
    fifth_room.found = 0

    x = 148720
    while x < 149175
      this_npc = DMCNpc.new
      this_npc.npc = add_spawn(BS[idx], x, 182145, -6117, 48810, false, 0, false, world.instance_id)
      this_npc.npc.no_rnd_walk = true
      this_npc.order = idx
      this_npc.status = temp[idx]
      this_npc.count = 0
      fifth_room.npc_list << this_npc
      if temp[idx] == 1 && Rnd.rand(100) < 95
        this_npc.npc.broadcast_packet(NpcSay.new(this_npc.npc.l2id, 0, this_npc.npc.id, SPAWN_CHAT.sample))
      elsif temp[idx] != 1 && Rnd.rand(100) < 67
        this_npc.npc.broadcast_packet(NpcSay.new(this_npc.npc.l2id, 0, this_npc.npc.id, SPAWN_CHAT.sample))
      end
      x +=65
      idx += 1
    end

    world.rooms[:FifthRoom] = fifth_room
  end

  private def check_kill_progress(npc, room)
    cont = true
    room.npc_list.each do |npc_obj|
      if npc_obj.npc == npc
        npc_obj.dead = true
      end
      unless npc_obj.dead?
        cont = false
      end
    end

    cont
  end

  private def spawn_rnd_golem(world, npc)
    if npc.golem?
      return
    end

    # i = rand(GOLEM_SPAWN.size)
    # mob_id = GOLEM_SPAWN[i][0]
    # x = GOLEM_SPAWN[i][1]
    # y = GOLEM_SPAWN[i][2]
    mob_id, x, y = GOLEM_SPAWN.sample

    npc.golem = add_spawn(mob_id, x, y, -6117, 0, false, 0, false, world.instance_id)
    if @no_random_walk
      npc.golem.no_rnd_walk = true
    end
  end

  private def check_stone(npc, order, npc_obj, world)
    1.upto(6) do |i|
      # if there is a non zero value in the precedent step, the sequence is ok
      if order[i] == 0 && order[i - 1] != 0
        if npc_obj.order == i && npc_obj.status == 0
          order[i] = 1
          npc_obj.status = 1
          npc_obj.dead = true
          npc.broadcast_packet(MagicSkillUse.new(npc, npc, 5441, 1, 1, 0))
          return
        end
      end
    end

    spawn_rnd_golem(world, npc_obj)
  end

  private def end_instance(world)
    world.status = 10
    add_spawn(SYM_TRUTH, 148911, 181940, -6117, 16383, false, 0, false, world.instance_id)
    world.rooms.clear
  end

  private def check_beleth_sample(world, npc, player)
    fifth_room = world.rooms[:FifthRoom]

    fifth_room.npc_list.each do |mob|
      if mob.npc? == npc
        if mob.count == 0
          mob.count = 1
          if mob.status == 1
            mob.npc.broadcast_packet(NpcSay.new(mob.npc.l2id, Say2::NPC_ALL, mob.npc.id, SUCCESS_CHAT.sample))
            fifth_room.found += 1
            start_quest_timer("decayMe", 1500, npc, player)
          else
            fifth_room.reset = 1
            mob.npc.broadcast_packet(NpcSay.new(mob.npc.l2id, Say2::NPC_ALL, mob.npc.id, FAILED_CHAT.sample))
            start_quest_timer("decayChatBelethSamples", 4000, npc, player)
            start_quest_timer("decayBelethSamples", 4500, npc, player)
          end
        else
          return
        end
      end
    end
  end

  private def killed_beleth_sample(world, npc)
    decayed_samples = 0
    fifth_room = world.rooms[:FifthRoom]

    fifth_room.npc_list.each do |mob|
      if mob.npc? == npc
        decayed_samples += 1
        mob.count = 2
      else
        if mob.count == 2
          decayed_samples += 1
        end
      end
    end

    if fifth_room.reset == 1
      fifth_room.npc_list.each do |mob|
        if mob.count == 0 || mob.status == 1 && mob.count != 2
          decayed_samples += 1
          mob.npc.decay_me
          mob.count = 2
        end
      end
      if decayed_samples == 7
        start_quest_timer("respawnFifth", 6000, npc, nil)
      end
    else
      if fifth_room.reset == 0 && fifth_room.found == 3
        fifth_room.npc_list.each do |mob|
          mob.npc.decay_me
        end
        end_instance(world)
      end
    end
  end

  private def all_stones_done(world)
    second_room = world.rooms[:SecondRoom]
    second_room.npc_list.all? &.dead?
  end

  private def removeMonoliths(world)
    second_room = world.rooms[:SecondRoom]
    second_room.npc_list.each &.npc.decay_me
  end

  private def chkShadowColumn(world, npc)
    fourth_room = world.rooms[:FourthRoom]

    fourth_room.npc_list.each do |mob|
      if mob.npc? == npc
        7.times do |i|
          if mob.order == i && fourth_room.counter == i
            open_door(W1 + i, world.instance_id)
            fourth_room.counter += 1
            if fourth_room.counter == 7
              run_third_room2(world)
            end
          end
        end
      end
    end
  end

  def on_adv_event(event, npc, player)
    unless npc
      return ""
    end

    world = InstanceManager.get_world(npc.instance_id)
    unless world.is_a?(DMCWorld)
      return ""
    end

    if world.rooms.has_key?(:FifthRoom)
      fifth_room = world.rooms[:FifthRoom]
      if event.casecmp?("decayMe")
        fifth_room.npc_list.each do |mob|
          if mob.npc? == npc || fifth_room.reset == 0 && fifth_room.found == 3
            mob.npc.decay_me
            mob.count = 2
          end
        end
        if fifth_room.reset == 0 && fifth_room.found == 3
          end_instance(world)
        end
      elsif event.casecmp?("decayBelethSamples")
        fifth_room.npc_list.each do |mob|
          if mob.count == 0
            mob.npc.decay_me
            mob.count = 2
          end
        end
      elsif event.casecmp?("decayChatBelethSamples")
        fifth_room.npc_list.each do |mob|
          if mob.status == 1
            mob.npc.broadcast_packet(NpcSay.new(mob.npc.l2id, Say2::NPC_ALL, mob.npc.id, DECAY_CHAT.sample))
          end
        end
      elsif event.casecmp?("respawnFifth")
        spawn_fifth_room(world)
      end
    end

    ""
 end

  def on_kill(npc, player, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(DMCWorld)
      if world.status == 0
        if check_kill_progress(npc, world.rooms[:StartRoom])
          run_hall(world)
        end
      end
      if world.status == 1
        if check_kill_progress(npc, world.rooms[:Hall])
          run_first_room(world)
        end
      end
      if world.status == 2
        if check_kill_progress(npc, world.rooms[:FirstRoom])
          run_hall_2(world)
        end
      end
      if world.status == 3
        if check_kill_progress(npc, world.rooms[:Hall])
          run_second_room(world)
        end
      end
      if world.status == 4
        second_room = world.rooms[:SecondRoom]
        second_room.npc_list.each do |mob|
          if mob.golem? == npc
            mob.golem = nil
          end
        end
      end
      if world.status == 5
        if check_kill_progress(npc, world.rooms[:Hall])
          run_third_room(world)
        end
      end
      if world.status == 6
        if check_kill_progress(npc, world.rooms[:ThirdRoom])
          run_fourth_room(world)
        end
      end
      if world.status == 7
        chkShadowColumn(world, npc)
      end
      if world.status == 8
        if check_kill_progress(npc, world.rooms[:ThirdRoom2])
          run_fifth_room(world)
        end
      end
      if world.status == 9
        killed_beleth_sample(world, npc)
      end
    end

    ""
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(DMCWorld)
      if world.status == 7
        fourth_room = world.rooms[:FourthRoom]
        fourth_room.npc_list.each do |mob|
          if mob.npc? == npc
            if mob.npc.invul? && Rnd.rand(100) < 12
              add_spawn(BM.sample, *attacker.xyz, 0, false, 0, false, world.instance_id)
            end
          end
        end
      end
      if world.status == 9
        check_beleth_sample(world, npc, attacker)
      end
    end

    super
  end

  def on_first_talk(npc, player)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(DMCWorld)
      if world.status == 4
        second_room = world.rooms[:SecondRoom]
        second_room.npc_list.each do |mob|
          if mob.npc? == npc
            check_stone(npc, second_room.order, mob, world)
          end
        end

        if all_stones_done(world)
          removeMonoliths(world)
          run_hall3(world)
        end
      end

      if npc.id == SYM_TRUTH && world.status == 10
        npc.show_chat_window(player)

        unless has_quest_items?(player, CC)
          give_items(player, CC, 1)
        end
      end
    end

    ""
  end

  def on_talk(npc, player)
    npc_id = npc.id
    if npc_id == YIYEN
      enter_instance(player, DMCWorld.new, "DarkCloudMansion.xml", TEMPLATE_ID)
    else
      world = InstanceManager.get_world(npc.instance_id)
      unless world.is_a?(DMCWorld)
        return ""
      end

      if npc_id == SYM_TRUTH
        if world.allowed?(player.l2id)
          world.remove_allowed(player.l2id)
        end
        teleport_player(player, Location.new(139968, 150367, -3111), 0)
        instance_id = npc.instance_id
        instance = InstanceManager.get_instance!(instance_id)
        if instance.players.empty?
          InstanceManager.destroy_instance(instance_id)
        end

        return ""
      end
    end

    ""
  end
end
