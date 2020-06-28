class Scripts::CavernOfThePirateCaptain < AbstractInstance
  private class CavernOfThePirateCaptainWorld < InstanceWorld
    getter players_inside = [] of L2PcInstance
    property store_time : Int64 = 0i64
    property zaken_room : Int32 = 0
    property blue_found : Int32 = 0
    property! zaken : L2Attackable
    property? is_83 : Bool = false
  end

  # NPCs
  private PATHFINDER = 32713 # Pathfinder Worker
  private ZAKEN_60 = 29176 # Zaken
  private ZAKEN_83 = 29181 # Zaken
  private CANDLE = 32705 # Zaken's Candle
  private DOLL_BLADER_60 = 29023 # Doll Blader
  private DOLL_BLADER_83 = 29182 # Doll Blader
  private VALE_MASTER_60 = 29024 # Veil Master
  private VALE_MASTER_83 = 29183 # Veil Master
  private PIRATES_ZOMBIE_60 = 29027 # Pirate Zombie
  private PIRATES_ZOMBIE_83 = 29185 # Pirate Zombie
  private PIRATES_ZOMBIE_CAPTAIN_60 = 29026 # Pirate Zombie Captain
  private PIRATES_ZOMBIE_CAPTAIN_83 = 29184 # Pirate Zombie Captain
  # Items
  private VORPAL_RING = 15763 # Sealed Vorpal Ring
  private VORPAL_EARRING = 15764 # Sealed Vorpal Earring
  private FIRE = 15280 # Transparent 1HS (for NPC)
  private RED = 15281 # Transparent 1HS (for NPC)
  private BLUE = 15302 # Transparent Bow (for NPC)
  # Locations
  private ENTER_LOC = {
    Location.new(52684, 219989, -3496),
    Location.new(52669, 219120, -3224),
    Location.new(52672, 219439, -3312)
  }
  private CANDLE_LOC = {
    # Floor 1
    Location.new(53313, 220133, -3498),
    Location.new(53313, 218079, -3498),
    Location.new(54240, 221045, -3498),
    Location.new(54325, 219095, -3498),
    Location.new(54240, 217155, -3498),
    Location.new(55257, 220028, -3498),
    Location.new(55257, 218172, -3498),
    Location.new(56280, 221045, -3498),
    Location.new(56195, 219095, -3498),
    Location.new(56280, 217155, -3498),
    Location.new(57215, 220133, -3498),
    Location.new(57215, 218079, -3498),
    # Floor 2
    Location.new(53313, 220133, -3226),
    Location.new(53313, 218079, -3226),
    Location.new(54240, 221045, -3226),
    Location.new(54325, 219095, -3226),
    Location.new(54240, 217155, -3226),
    Location.new(55257, 220028, -3226),
    Location.new(55257, 218172, -3226),
    Location.new(56280, 221045, -3226),
    Location.new(56195, 219095, -3226),
    Location.new(56280, 217155, -3226),
    Location.new(57215, 220133, -3226),
    Location.new(57215, 218079, -3226),
    # Floor 3
    Location.new(53313, 220133, -2954),
    Location.new(53313, 218079, -2954),
    Location.new(54240, 221045, -2954),
    Location.new(54325, 219095, -2954),
    Location.new(54240, 217155, -2954),
    Location.new(55257, 220028, -2954),
    Location.new(55257, 218172, -2954),
    Location.new(56280, 221045, -2954),
    Location.new(56195, 219095, -2954),
    Location.new(56280, 217155, -2954),
    Location.new(57215, 220133, -2954),
    Location.new(57215, 218079, -2954)
  }
  # Misc
  private MIN_LV_60 = 55
  private MIN_LV_83 = 78
  private PLAYERS_60_MIN = 9
  private PLAYERS_60_MAX = 27
  private PLAYERS_83_MIN = 9
  private PLAYERS_83_MAX = 27
  private TEMPLATE_ID_60 = 133
  private TEMPLATE_ID_83 = 135
  private ROOM_DATA = {
    # Floor 1
    {54240, 220133, -3498, 1, 3, 4, 6},
    {54240, 218073, -3498, 2, 5, 4, 7},
    {55265, 219095, -3498, 4, 9, 6, 7},
    {56289, 220133, -3498, 8, 11, 6, 9},
    {56289, 218073, -3498, 10, 12, 7, 9},
    # Floor 2
    {54240, 220133, -3226, 13, 15, 16, 18},
    {54240, 218073, -3226, 14, 17, 16, 19},
    {55265, 219095, -3226, 21, 16, 19, 18},
    {56289, 220133, -3226, 20, 23, 21, 18},
    {56289, 218073, -3226, 22, 24, 19, 21},
    # Floor 3
    {54240, 220133, -2954, 25, 27, 28, 30},
    {54240, 218073, -2954, 26, 29, 28, 31},
    {55265, 219095, -2954, 33, 28, 31, 30},
    {56289, 220133, -2954, 32, 35, 30, 33},
    {56289, 218073, -2954, 34, 36, 31, 33}
  }

  def initialize
    super(self.class.simple_name)

    add_start_npc(PATHFINDER)
    add_talk_id(PATHFINDER)
    add_kill_id(ZAKEN_60, ZAKEN_83)
    add_first_talk_id(CANDLE)
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world = world.as(CavernOfThePirateCaptainWorld)
      world.is_83 = world.template_id == TEMPLATE_ID_83
      world.store_time = Time.ms

      party = pc.party
      if party.nil?
        manage_player_enter(pc, world)
      elsif cc = party.command_channel
        cc.members.each do |m|
          manage_player_enter(m, world)
        end
      else
        party.members.each do |m|
          manage_player_enter(m, world)
        end
      end
      manage_npc_spawn(world)
    else
      teleport_player(pc, ENTER_LOC.sample(random: Rnd), world.instance_id, false)
    end
  end

  private def manage_player_enter(pc, world)
    world.players_inside << pc
    world.add_allowed(pc.l2id)
    teleport_player(pc, ENTER_LOC.sample(random: Rnd), world.instance_id, false)
  end

  private def check_conditions(player, template_id)
    if player.override_instance_conditions?
      return true
    end

    unless party = player.party
      broadcast_sm(player, nil, SystemMessageId::NOT_IN_PARTY_CANT_ENTER, false)
      return false
    end

    is83 = template_id == TEMPLATE_ID_83
    cc = party.command_channel
    members = cc ? cc.members : party.members
    is_party_leader = cc ? cc.leader?(player) : party.leader?(player)

    unless is_party_leader
      broadcast_sm(player, nil, SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER, false)
      return false
    end

    if members.size < (is83 ? PLAYERS_83_MIN : PLAYERS_60_MIN) || members.size > (is83 ? PLAYERS_83_MAX : PLAYERS_60_MAX)
      broadcast_sm(player, nil, SystemMessageId::PARTY_EXCEEDED_THE_LIMIT_CANT_ENTER, false)
      return false
    end

    members.each do |m|
      if m.level < (is83 ? MIN_LV_83 : MIN_LV_60)
        broadcast_sm(player, m, SystemMessageId::C1_S_LEVEL_REQUIREMENT_IS_NOT_SUFFICIENT_AND_CANNOT_BE_ENTERED, true)
        return false
      end

      unless player.inside_radius?(m, 1000, true, true)
        broadcast_sm(player, m, SystemMessageId::C1_IS_IN_A_LOCATION_WHICH_CANNOT_BE_ENTERED_THEREFORE_IT_CANNOT_BE_PROCESSED, true)
        return false
      end

      reentertime = InstanceManager.get_instance_time(m.l2id, (is83 ? TEMPLATE_ID_83 : TEMPLATE_ID_60))
      if Time.ms < reentertime
        broadcast_sm(player, m, SystemMessageId::C1_MAY_NOT_RE_ENTER_YET, true)
        return false
      end
    end

    true
  end

  private def broadcast_sm(pc, member, sm_id, to_group)
    sm = SystemMessage[sm_id]

    if to_group && member
      party = pc.party.not_nil!
      sm.add_pc_name(member)

      if cc = party.command_channel
        cc.broadcast_packet(sm)
      else
        party.broadcast_packet(sm)
      end
    else
      pc.broadcast_packet(sm)
    end
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    npc = npc.not_nil!

    if event == "enter60"
      enter_instance(pc, CavernOfThePirateCaptainWorld.new, "CavernOfThePirateCaptainWorldDay60.xml", TEMPLATE_ID_60)
    elsif event == "enter83"
      enter_instance(pc, CavernOfThePirateCaptainWorld.new, "CavernOfThePirateCaptainWorldDay83.xml", TEMPLATE_ID_83)
    else
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CavernOfThePirateCaptainWorld)
        case event
        when "BURN_BLUE"
          if npc.right_hand_item == 0
            npc.r_hand_id = FIRE
            start_quest_timer("BURN_BLUE2", 3000, npc, pc)
            if world.blue_found == 4
              start_quest_timer("SHOW_ZAKEN", 5000, npc, pc)
            end
          end
        when "BURN_BLUE2"
          if npc.right_hand_item == FIRE
            npc.r_hand_id = BLUE
          end
        when "BURN_RED"
          if npc.right_hand_item == 0
            npc.r_hand_id = FIRE
            start_quest_timer("BURN_RED2", 3000, npc, pc)
          end
        when "BURN_RED2"
          if npc.right_hand_item == FIRE
            room = get_room_by_candle(npc)
            npc.r_hand_id = RED
            manage_screen_msg(world, NpcString::THE_CANDLES_CAN_LEAD_YOU_TO_ZAKEN_DESTROY_HIM)
            spawn_npc(world.is_83? ? DOLL_BLADER_83 : DOLL_BLADER_60, room, pc, world)
            spawn_npc(world.is_83? ? VALE_MASTER_83 : VALE_MASTER_60, room, pc, world)
            spawn_npc(world.is_83? ? PIRATES_ZOMBIE_83 : PIRATES_ZOMBIE_60, room, pc, world)
            spawn_npc(world.is_83? ? PIRATES_ZOMBIE_CAPTAIN_83 : PIRATES_ZOMBIE_CAPTAIN_60, room, pc, world)
          end
        when "SHOW_ZAKEN"
          if world.is_83?
            manage_screen_msg(world, NpcString::WHO_DARES_AWKAWEN_THE_MIGHTY_ZAKEN)
          end
          world.zaken.invisible = false
          world.zaken.paralyzed = false
          spawn_npc(world.is_83? ? DOLL_BLADER_83 : DOLL_BLADER_60, world.zaken_room, pc, world)
          spawn_npc(world.is_83? ? PIRATES_ZOMBIE_83 : PIRATES_ZOMBIE_60, world.zaken_room, pc, world)
          spawn_npc(world.is_83? ? PIRATES_ZOMBIE_CAPTAIN_83 : PIRATES_ZOMBIE_CAPTAIN_60, world.zaken_room, pc, world)
        end

      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    world = InstanceManager.get_world(npc.instance_id)

    if world.is_a?(CavernOfThePirateCaptainWorld)
      if npc.id == ZAKEN_83
        world.players_inside.each do |pc|
          if pc.instance_id == world.instance_id
            if pc.inside_radius?(npc, 1500, true, true)
              time = Time.ms - world.store_time
              if time <= 300000 # 5 minutes
                if Rnd.bool
                  give_items(pc, VORPAL_RING, 1)
                end
              elsif time <= 600000 # 10 minutes
                if Rnd.rand(100) < 30
                  give_items(pc, VORPAL_EARRING, 1)
                end
              elsif time <= 900000 # 15 minutes
                if Rnd.rand(100) < 25
                  give_items(pc, VORPAL_RING, 1)
                end
              end
            end
          end
        end
      end

      finish_instance(world)
    end

    super
  end

  def on_first_talk(npc, pc)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(CavernOfThePirateCaptainWorld)
      if npc.script_value?(0)
        if npc.variables.get_i32("isBlue", 0) == 1
          world.blue_found += 1
          start_quest_timer("BURN_BLUE", 500, npc, pc)
        else
          start_quest_timer("BURN_RED", 500, npc, pc)
        end
        npc.script_value = 1
      end
    end

    nil
  end

  private def get_room_by_candle(npc)
    candle_id = npc.variables.get_i32("candleId", 0)

    15.times do |i|
      if ROOM_DATA[i][3] == candle_id || ROOM_DATA[i][4] == candle_id
        return i &+ 1
      end
    end

    case candle_id
    when 6, 7
      return 3
    when 18, 19
      return 8
    when 30, 31
      return 13
    end


    0
  end

  private def manage_screen_msg(world, string_id)
    world.players_inside.each do |pc|
      if pc.instance_id == world.instance_id
        show_on_screen_msg(pc, string_id, 2, 6000)
      end
    end
  end

  private def spawn_npc(npc_id, room_id, pc, world)
    if npc_id != ZAKEN_60 && npc_id != ZAKEN_83
      mob = add_spawn(npc_id, ROOM_DATA[room_id - 1][0] + Rnd.rand(350), ROOM_DATA[room_id - 1][1] + Rnd.rand(350), ROOM_DATA[room_id - 1][2], 0, false, 0, false, world.instance_id).as(L2Attackable)
      add_attack_desire(mob, pc) if pc
      return mob
    end

    add_spawn(npc_id, ROOM_DATA[room_id - 1][0], ROOM_DATA[room_id - 1][1], ROOM_DATA[room_id - 1][2], 0, false, 0, false, world.instance_id).as(L2Attackable)
  end

  private def manage_npc_spawn(world)
    candles = [] of L2Npc
    world.zaken_room = Rnd.rand(1..15)

    36.times do |i|
      candle = add_spawn(CANDLE, CANDLE_LOC[i], false, 0, false, world.instance_id)
      candle.variables["candleId"] = i &+ 1
      candles.push(candle)
    end

    3.upto(6) do |i|
      candles[ROOM_DATA[world.zaken_room &- 1][i] - 1].variables["isBlue"] = 1
    end
    world.zaken = spawn_npc(world.is_83? ? ZAKEN_83 : ZAKEN_60, world.zaken_room, nil, world)
    world.zaken.invisible = true
    world.zaken.paralyzed = true
  end
end
