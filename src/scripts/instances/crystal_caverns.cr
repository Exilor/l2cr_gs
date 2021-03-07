class Scripts::CrystalCaverns < AbstractInstance
  private class CrystalGolem
    property! food_item : L2ItemInstance?
    property? at_destination = false
    property! old_loc : Location?
  end

  private class CCWorld < InstanceWorld
    getter npc_list1 = {} of L2Npc => Bool
    getter oracle_triggered = [false, false, false]
    getter room_status = [0, 0, 0, 0] # 0: not spawned, 1: spawned, 2: cleared
    getter copies = [] of L2Npc
    getter crystal_golems = {} of L2Npc => CrystalGolem
    getter opened_doors = Concurrent::Map(L2DoorInstance, L2PcInstance).new
    getter npc_list_2 = {} of Int32 => Hash(L2Npc, Bool)
    getter oracles = {} of L2Npc => L2Npc?
    getter key_keepers = [] of L2Npc
    getter guards = [] of L2Npc
    getter oracle = [] of L2Npc
    getter raiders = [] of L2PcInstance
    getter animation_mobs = [] of L2Npc

    property has_used_invul_skill : Bool = false
    property dragon_scale_start : Int64 = 0i64
    property dragon_scale_needed : Int32 = 0
    property cleaned_rooms : Int32 = 0
    property end_time : Int64
    property correct_golems : Int32 = 0
    property kechis_henchman_spawn : Int32 = 0
    property raid_status : Int32 = 0
    property dragon_claw_start : Int64 = 0i64
    property dragon_claw_need : Int32 = 0

    property! camera : L2Npc?
    property! baylor : L2Npc?
    property! alarm : L2Npc?
    property! tears : L2Npc?

    initializer end_time : Int64
  end

  # Items
  private WHITE_SEED_OF_EVIL_SHARD = 9597
  private BLACK_SEED_OF_EVIL_SHARD = 9598
  private CONTAMINATED_CRYSTAL = 9690
  private RED_CORAL = 9692
  private CRYSTAL_FRAGMENT = 9693
  private SECRET_KEY = 9694
  private BLUE_CRYSTAL = 9695
  private RED_CRYSTAL = 9696
  private CLEAR_CRYSTAL = 9697
  # NPCs
  private ORACLE_GUIDE_1 = 32281
  private ORACLE_GUIDE_2 = 32278
  private ORACLE_GUIDE_3 = 32280
  private ORACLE_GUIDE_4 = 32279
  private CRYSTALLINE_GOLEM = 32328
  private DOOR_OPENING_TRAP = {
    18378,
    143680,
    142608,
    -11845,
    0
  }
  private GATEKEEPER_LOHAN = 22275
  private GATEKEEPER_PROVO = 22277
  private TOURMALINE = 22292
  private TEROD = 22301
  private DOLPH = 22299
  private WEYLIN = 22298
  private GUARDIAN_OF_THE_SQUARE = 22303
  private GUARDIAN_OF_THE_EMERALD = 22304
  private TEARS = 25534
  private TEARS_COPY = 25535
  private KECHI = 25532
  private KECHIS_HENCHMAN = 25533
  private BAYLOR = 29099
  private DARNEL = 25531
  private ALARM = 18474
  private CGMOBS = {
    22311,
    22312,
    22313,
    22314,
    22315,
    22316,
    22317
  }
  private SPAWN = {
    60000,
    120000,
    90000,
    60000,
    50000,
    40000
  } # Kechi Henchmans spawn times
  private MOBLIST = {
    22279,
    22280,
    22281,
    22282,
    22283,
    22285,
    22286,
    22287,
    22288,
    22289,
    22293,
    22294,
    22295,
    22296,
    22297,
    22305,
    22306,
    22307,
    22416,
    22418,
    22419,
    22420
  }

  # Locations
  private START_LOC = Location.new(143348, 148707, -11972)
  # Skills
  private BERSERK = SkillHolder.new(5224)
  private INVINCIBLE = SkillHolder.new(5225)
  private STRONG_PUNCH = SkillHolder.new(5229)
  private EVENT_TIMER_1 = SkillHolder.new(5239)
  private EVENT_TIMER_2 = SkillHolder.new(5239, 2)
  private EVENT_TIMER_3 = SkillHolder.new(5239, 3)
  private EVENT_TIMER_4 = SkillHolder.new(5239, 4)
  private PHYSICAL_UP = SkillHolder.new(5244)
  private MAGICAL_UP = SkillHolder.new(5245)
  # Misc
  private TEMPLATE_ID = 10
  private MIN_LEVEL = 78
  private DOOR1 = 24220021
  private DOOR2 = 24220024
  private DOOR3 = 24220023
  private DOOR4 = 24220061
  private DOOR5 = 24220025
  private DOOR6 = 24220022
  private ZONES = {
    20105,
    20106,
    20107
  }

  private ALARM_SPAWN = {
    {153572, 141277, -12738},
    {153572, 142852, -12738},
    {154358, 142075, -12738},
    {152788, 142075, -12738}
  }
  # Oracle order
  private ORDER_ORACLE1 = {
    {32274, 147090, 152505, -12169, 31613},
    {32275, 147090, 152575, -12169, 31613},
    {32274, 147090, 152645, -12169, 31613},
    {32274, 147090, 152715, -12169, 31613}
  }

  private ORDER_ORACLE2 = {
    {32274, 149783, 152505, -12169, 31613},
    # {32274, 149783, 152575, -12169, 31613},
    {32274, 149783, 152645, -12169, 31613},
    {32276, 149783, 152715, -12169, 31613}
  }

  private ORDER_ORACLE3 = {
    {32274, 152461, 152505, -12169, 31613},
    # {32274, 152461, 152575, -12169, 31613},
    {32277, 152461, 152645, -12169, 31613},
    # {32274, 152461, 152715, -12169, 31613}
  }
  private HALL_SPAWNS = {
    {141842, 152556, -11814, 50449},
    {141503, 153395, -11814, 40738},
    {141070, 153201, -11814, 39292},
    {141371, 152986, -11814, 35575},
    {141602, 154188, -11814, 24575},
    {141382, 154719, -11814, 37640},
    {141376, 154359, -11814, 12054},
    {140895, 154383, -11814, 37508},
    {140972, 154740, -11814, 52690},
    {141045, 154504, -11814, 50674},
    {140757, 152740, -11814, 39463},
    {140406, 152376, -11814, 16599},
    {140268, 152007, -11817, 45316},
    {139996, 151485, -11814, 47403},
    {140378, 151190, -11814, 58116},
    {140521, 150711, -11815, 55997},
    {140816, 150215, -11814, 53682},
    {141528, 149909, -11814, 22020},
    {141644, 150360, -11817, 13283},
    {142048, 150695, -11815, 5929},
    {141852, 151065, -11817, 27071},
    {142408, 151211, -11815, 2402},
    {142481, 151762, -11815, 12876},
    {141929, 152193, -11815, 27511},
    {142083, 151791, -11814, 47176},
    {141435, 150402, -11814, 41798},
    {140390, 151199, -11814, 50069},
    {140557, 151849, -11814, 45293},
    {140964, 153445, -11814, 56672},
    {142851, 154109, -11814, 24920},
    {142379, 154725, -11814, 30342},
    {142816, 154712, -11814, 33193},
    {142276, 154223, -11814, 33922},
    {142459, 154490, -11814, 33184},
    {142819, 154372, -11814, 21318},
    {141157, 154541, -11814, 27090},
    {141095, 150281, -11814, 55186}
  }

  # first spawns
  private FIRST_SPAWNS = {
    {22276, 148109, 149601, -12132, 34490},
    {22276, 148017, 149529, -12132, 33689},
    {22278, 148065, 151202, -12132, 35323},
    {22278, 147966, 151117, -12132, 33234},
    {22279, 144063, 150238, -12132, 29654},
    {22279, 144300, 149118, -12135, 5520},
    {22279, 144397, 149337, -12132, 644},
    {22279, 144426, 150639, -12132, 50655},
    {22282, 145841, 151097, -12132, 31810},
    {22282, 144387, 149958, -12132, 61173},
    {22282, 145821, 149498, -12132, 31490},
    {22282, 146619, 149694, -12132, 33374},
    {22282, 146669, 149244, -12132, 31360},
    {22284, 144147, 151375, -12132, 58395},
    {22284, 144485, 151067, -12132, 64786},
    {22284, 144356, 149571, -12132, 63516},
    {22285, 144151, 150962, -12132, 664},
    {22285, 146657, 151365, -12132, 33154},
    {22285, 146623, 150857, -12132, 28034},
    {22285, 147046, 151089, -12132, 32941},
    {22285, 145704, 151255, -12132, 32523},
    {22285, 145359, 151101, -12132, 32767},
    {22285, 147785, 150817, -12132, 27423},
    {22285, 147727, 151375, -12132, 37117},
    {22285, 145428, 149494, -12132, 890},
    {22285, 145601, 149682, -12132, 32442},
    {22285, 147003, 149476, -12132, 31554},
    {22285, 147738, 149210, -12132, 20971},
    {22285, 147769, 149757, -12132, 34980}
  }

  # Emerald Square
  private EMERALD_SPAWNS = {
    {22280, 144437, 143395, -11969, 34248},
    {22281, 149241, 143735, -12230, 24575},
    {22281, 147917, 146861, -12289, 60306},
    {22281, 144406, 147782, -12133, 14349},
    {22281, 144960, 146881, -12039, 23881},
    {22281, 144985, 147679, -12135, 27594},
    {22283, 147784, 143540, -12222, 2058},
    {22283, 149091, 143491, -12230, 24836},
    {22287, 144479, 147569, -12133, 20723},
    {22287, 145158, 146986, -12058, 21970},
    {22287, 145142, 147175, -12092, 24420},
    {22287, 145110, 147133, -12088, 22465},
    {22287, 144664, 146604, -12028, 14861},
    {22287, 144596, 146600, -12028, 14461},
    {22288, 143925, 146773, -12037, 10813},
    {22288, 144415, 147070, -12069, 8568},
    {22288, 143794, 145584, -12027, 14849},
    {22288, 143429, 146166, -12030, 4078},
    {22288, 144477, 147009, -12056, 8752},
    {22289, 142577, 145319, -12029, 5403},
    {22289, 143831, 146902, -12051, 9717},
    {22289, 143714, 146705, -12028, 10044},
    {22289, 143937, 147134, -12078, 7517},
    {22293, 143356, 145287, -12027, 8126},
    {22293, 143462, 144352, -12008, 25905},
    {22293, 143745, 142529, -11882, 17102},
    {22293, 144574, 144032, -12005, 34668},
    {22295, 143992, 142419, -11884, 19697},
    {22295, 144671, 143966, -12004, 32088},
    {22295, 144440, 143269, -11957, 34169},
    {22295, 142642, 146362, -12028, 281},
    {22295, 143865, 142707, -11881, 21326},
    {22295, 143573, 142530, -11879, 16141},
    {22295, 143148, 146039, -12031, 65014},
    {22295, 143001, 144853, -12014, 0},
    {22296, 147505, 146580, -12260, 59041},
    {22296, 149366, 146932, -12358, 39407},
    {22296, 149284, 147029, -12352, 41120},
    {22296, 149439, 143940, -12230, 23189},
    {22296, 147698, 143995, -12220, 27028},
    {22296, 141885, 144969, -12007, 2526},
    {22296, 147843, 143763, -12220, 28386},
    {22296, 144753, 143650, -11982, 35429},
    {22296, 147613, 146760, -12271, 56296}
  }

  private ROOM1_SPAWNS = {
    {22288, 143114, 140027, -11888, 15025},
    {22288, 142173, 140973, -11888, 55698},
    {22289, 143210, 140577, -11888, 17164},
    {22289, 142638, 140107, -11888, 6571},
    {22297, 142547, 140938, -11888, 48556},
    {22298, 142690, 140479, -11887, 7663}
  }

  private ROOM2_SPAWNS = {
    {22303, 146276, 141483, -11880, 34643},
    {22287, 145707, 142161, -11880, 28799},
    {22288, 146857, 142129, -11880, 33647},
    {22288, 146869, 142000, -11880, 31215},
    {22289, 146897, 140880, -11880, 19210}
  }

  private ROOM3_SPAWNS = {
    {22302, 145123, 143713, -12808, 65323},
    {22294, 145188, 143331, -12808, 496},
    {22294, 145181, 144104, -12808, 64415},
    {22293, 144994, 143431, -12808, 65431},
    {22293, 144976, 143915, -12808, 61461}
  }

  private ROOM4_SPAWNS = {
    {22304, 150563, 142240, -12108, 16454},
    {22294, 150769, 142495, -12108, 16870},
    {22281, 150783, 141995, -12108, 20033},
    {22283, 150273, 141983, -12108, 16043},
    {22294, 150276, 142492, -12108, 13540}
  }

  # Steam Corridor
  private STEAM1_SPAWNS = {
    {22305, 145260, 152387, -12165, 32767},
    {22305, 144967, 152390, -12165, 30464},
    {22305, 145610, 152586, -12165, 17107},
    {22305, 145620, 152397, -12165, 8191},
    {22418, 146081, 152847, -12165, 31396},
    {22418, 146795, 152641, -12165, 33850},
    # {22308, 145093, 152502, -12165, 31841},
    # {22308, 146158, 152776, -12165, 30810},
    # {22308, 146116, 152976, -12133, 32571}

  }
  private STEAM2_SPAWNS = {
    {22306, 147740, 152767, -12165, 65043},
    {22306, 148215, 152828, -12165, 970},
    {22306, 147743, 152846, -12165, 64147},
    # {22308, 147849, 152854, -12165, 60534},
    # {22308, 147754, 152908, -12141, 59827},
    # {22308, 148194, 152681, -12165, 63620},
    # {22308, 147767, 152939, -12133, 63381},
    # {22309, 147737, 152671, -12165, 65320},
    {22418, 148207, 152725, -12165, 61801},
    {22419, 149058, 152828, -12165, 64564}
  }

  private STEAM3_SPAWNS = {
    {22307, 150735, 152316, -12145, 31930},
    {22307, 150725, 152467, -12165, 33635},
    {22307, 151058, 152316, -12146, 65342},
    {22307, 151057, 152461, -12165, 2171},
    # {22308, 150794, 152455, -12165, 31613},
    # {22308, 150665, 152383, -12165, 32767},
    # {22308, 151697, 152621, -12167, 31423},
    # {22309, 151061, 152581, -12165, 6228},
    # {22309, 150653, 152253, -12132, 31343},
    # {22309, 150628, 152431, -12165, 33022},
    # {22309, 151620, 152487, -12165, 30114},
    # {22309, 151672, 152544, -12165, 31846},
    # {22309, 150488, 152350, -12165, 29072},
    # {22310, 151139, 152238, -12132, 1069}
  }

  private STEAM4_SPAWNS = {
    # {22308, 151707, 150199, -12165, 32859},
    # {22308, 152091, 150140, -12165, 32938},
    # {22308, 149757, 150204, -12138, 65331},
    # {22308, 149950, 150307, -12132, 62437},
    # {22308, 149901, 150322, -12132, 62136},
    # {22309, 150071, 150173, -12165, 64943},
    {22416, 151636, 150280, -12142, 36869},
    {22416, 149893, 150232, -12165, 64258},
    {22416, 149864, 150110, -12165, 65054},
    {22416, 151926, 150218, -12165, 31613},
    {22420, 149986, 150051, -12165, 105},
    {22420, 151970, 149997, -12165, 32170},
    {22420, 150744, 150006, -12165, 63},
    # {22417, 149782, 150188, -12151, 64001}
  }

  private DRAGON_SCALE_TIME = 3000
  private DRAGON_CLAW_TIME = 3000

  def initialize
    super(self.class.simple_name)

    add_start_npc(ORACLE_GUIDE_1, ORACLE_GUIDE_4)
    add_talk_id(
      ORACLE_GUIDE_1, ORACLE_GUIDE_3, ORACLE_GUIDE_4, 32275, 32276, 32277
    )
    add_first_talk_id(
      ORACLE_GUIDE_1, ORACLE_GUIDE_2, ORACLE_GUIDE_4, CRYSTALLINE_GOLEM, 32274,
      32275, 32276, 32277
    )
    add_kill_id(
      TEARS, GATEKEEPER_LOHAN, GATEKEEPER_PROVO, TEROD, WEYLIN, DOLPH, DARNEL,
      KECHI, GUARDIAN_OF_THE_SQUARE, GUARDIAN_OF_THE_EMERALD, TOURMALINE,
      BAYLOR, ALARM
    )
    add_skill_see_id(BAYLOR, 25534, 32275, 32276, 32277)
    add_trap_action_id(DOOR_OPENING_TRAP[0])
    add_spell_finished_id(BAYLOR)
    add_attack_id(TEARS)
    add_kill_id(MOBLIST)
    add_kill_id(CGMOBS)
    add_enter_zone_id(ZONES)
    add_exit_zone_id(ZONES)
  end

  private def check_conditions(player)
    if player.override_instance_conditions?
      return true
    end

    unless party = player.party
      player.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end
    if party.leader != player
      player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end
    party.members.each do |m|
      if m.level < MIN_LEVEL
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      unless m.inventory.get_item_by_item_id(CONTAMINATED_CRYSTAL)
        sm = SystemMessage.c1_item_requirement_not_sufficient
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      unless Util.in_range?(1000, player, m, true)
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

  private def check_oracle_conditions(player)
    if player.override_instance_conditions?
      return true
    end

    unless party = player.party
      player.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end
    if party.leader != player
      player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end
    party.members.each do |m|
      unless m.inventory.get_item_by_item_id(RED_CORAL)
        sm = SystemMessage.c1_item_requirement_not_sufficient
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      unless Util.in_range?(1000, player, m, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
    end

    true
  end

  private def check_baylor_conditions(player)
    if player.override_instance_conditions?
      return true
    end

    unless party = player.party
      player.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end
    if party.leader != player
      player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end

    item_ids = {BLUE_CRYSTAL, RED_CRYSTAL, CLEAR_CRYSTAL}
    party.members.each do |m|
      # item1 = m.inventory.get_item_by_item_id(BLUE_CRYSTAL)
      # item2 = m.inventory.get_item_by_item_id(RED_CRYSTAL)
      # item3 = m.inventory.get_item_by_item_id(CLEAR_CRYSTAL)
      # if item1.nil? || item2.nil? || item3.nil?

      unless item_ids.all? { |id| m.inventory.get_item_by_item_id(id) }
        sm = SystemMessage.c1_item_requirement_not_sufficient
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      unless Util.in_range?(1000, player, m, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
    end

    true
  end

  # this should be handled from skill effect
  private def throw(effector, effected)
    # Get current position of the L2Character
    cur_x = effected.x
    cur_y = effected.y
    cur_z = effected.z

    # Calculate distance between effector and effected current position
    dx = (effector.x - cur_x).to_f
    dy = (effector.y - cur_y).to_f
    dz = (effector.z - cur_z).to_f
    # distance = Math.sqrt((dx * dx) + (dy * dy))
    distance = Math.hypot(dx, dy)
    offset = Math.min((distance + 300).to_i, 1400)

    # approximation for moving futher when z coordinates are different
    # TODO: handle Z axis movement better
    offset += dz.abs
    if offset < 5
      offset = 5
    end

    if distance < 1
      return
    end
    # Calculate movement angles needed
    sin = dy / distance
    cos = dx / distance

    # Calculate the new destination with offset included
    _x = effector.x - (offset * cos).to_i
    _y = effector.y - (offset * sin).to_i
    _z = effected.z

    dst = GeoData.move_check(*effected.xyz, _x, _y, _z, effected.instance_id)

    effected.broadcast_packet(FlyToLocation.new(effected, dst, FlyType::THROW_UP))

    # maybe is need force set X,Y,Z
    effected.set_xyz(dst)
    effected.broadcast_packet(ValidateLocation.new(effected))
  end

  def on_enter_instance(player, world, first_entrance)
    if first_entrance
      if player.party.nil?
        teleport_player(player, START_LOC, world.instance_id)
        world.add_allowed(player.l2id)
      else
        player.party.not_nil!.members.each do |m|
          teleport_player(m, START_LOC, world.instance_id)
          world.add_allowed(m.l2id)
        end
      end
      run_oracle(world.as(CCWorld))
    else
      teleport_player(player, START_LOC, world.instance_id)
    end
  end

  private def stop_attack(player)
    player.target = nil
    player.abort_attack
    player.abort_cast
    player.break_attack
    player.break_cast
    player.intention = AI::IDLE

    if pet = player.summon
      pet.target = nil
      pet.abort_attack
      pet.abort_cast
      pet.break_attack
      pet.break_cast
      pet.intention = AI::IDLE
    end
  end

  private def run_oracle(world : CCWorld)
    world.status = 0
    world.oracle << add_spawn(ORACLE_GUIDE_1, 143172, 148894, -11975, 0, false, 0, false, world.instance_id)
  end

  private def run_emerald(world : CCWorld)
    world.status = 1
    run_first(world)
    open_door(DOOR1, world.instance_id)
  end

  private def run_coral(world : CCWorld)
    world.status = 1
    run_hall(world)
    open_door(DOOR2, world.instance_id)
    open_door(DOOR5, world.instance_id)
  end

  private def run_hall(world : CCWorld)
    world.status = 2

    HALL_SPAWNS.each do |sp|
      mob = add_spawn(CGMOBS.sample(random: Rnd), sp[0], sp[1], sp[2], sp[3], false, 0, false, world.instance_id)
      world.npc_list1[mob] = false
    end
  end

  private def run_first(world : CCWorld)
    world.status = 2
    world.key_keepers << add_spawn(GATEKEEPER_LOHAN, 148206, 149486, -12140, 32308, false, 0, false, world.instance_id)
    world.key_keepers << add_spawn(GATEKEEPER_PROVO, 148203, 151093, -12140, 31100, false, 0, false, world.instance_id)

    FIRST_SPAWNS.each do |sp|
      add_spawn(sp[0], sp[1], sp[2], sp[3], sp[4], false, 0, false, world.instance_id)
    end
  end

  private def run_emerald_square(world : CCWorld)
    world.status = 3

    spawn_list = {} of L2Npc => Bool
    EMERALD_SPAWNS.each do |sp|
      mob = add_spawn(sp[0], sp[1], sp[2], sp[3], sp[4], false, 0, false, world.instance_id)
      spawn_list[mob] = false
    end
    world.npc_list_2[0] = spawn_list
  end

  private def run_emerald_rooms(world : CCWorld, spawn_list, room)
    spawned = {} of L2Npc => Bool
    spawn_list.each do |sp|
      mob = add_spawn(sp[0], sp[1], sp[2], sp[3], sp[4], false, 0, false, world.instance_id)
      spawned[mob] = false
    end
    if room == 1
      add_spawn(32359, 142110, 139896, -11888, 8033, false, 0, false, world.instance_id)
    end
    world.npc_list_2[room] = spawned
    world.room_status[room - 1] = 1
  end

  private def run_darnel(world : CCWorld)
    world.status = 9

    add_spawn(DARNEL, 152759, 145949, -12588, 21592, false, 0, false, world.instance_id)
    # TODO: missing traps
    open_door(24220005, world.instance_id)
    open_door(24220006, world.instance_id)
  end

  private def run_steam_rooms(world : CCWorld, spawn_list, status)
    world.status = status

    spawned = {} of L2Npc => Bool
    spawn_list.each do |sp|
      mob = add_spawn(sp[0], sp[1], sp[2], sp[3], sp[4], false, 0, false, world.instance_id)
      spawned[mob] = false
    end
    world.npc_list_2[0] = spawned
  end

  private def run_steam_oracles(world : CCWorld, oracle_order)
    world.oracles.clear
    oracle_order.each do |oracle|
      tmp = add_spawn(oracle[0], oracle[1], oracle[2], oracle[3], oracle[4], false, 0, false, world.instance_id)
      world.oracles[tmp] = nil
    end
  end

  private def check_kill_progress(room, mob, world : CCWorld)
    if world.npc_list_2[room].has_key?(mob)
      world.npc_list_2[room][mob] = true
    end
    world.npc_list_2[room].each_value do |is_dead|
      unless is_dead
        return false
      end
    end

    true
  end

  # /*
  #  * private def run_baylor_room(world : CCWorld) { world.status = 30; add_spawn(29101,152758,143479,-12706,52961,false,0,false,world.instance_id,0);#up power add_spawn(29101,151951,142078,-12706,65203,false,0,false,world.instance_id,0);#up power
  #  * add_spawn(29101,154396,140667,-12706,22197,false,0,false,world.instance_id,0);#up power add_spawn(29102,152162,141249,-12706,5511,false,0,false,world.instance_id,0);#down power add_spawn(29102,153571,140458,-12706,16699,false,0,false,world.instance_id,0);#down power
  #  * add_spawn(29102,154976,141265,-12706,26908,false,0,false,world.instance_id,0);#down power add_spawn(29102,155203,142071,-12706,31560,false,0,false,world.instance_id,0);#down power add_spawn(29102,154380,143468,-12708,43943,false,0,false,world.instance_id,0);#down power
  #  * add_spawn(32271,153573,142069,-9722,11175,false,0,false,world.instance_id); world.Baylor = add_spawn(BAYLOR,153557,142089,-12735,11175,false,0,false,world.instance_id,0); }
  #  */

  def on_first_talk(npc, player)
    if npc.id == ORACLE_GUIDE_1
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld)
        if world.status == 0 && world.oracle.includes?(npc)
          return "32281.htm" # TODO: Missing HTML.
        end
      end
      npc.show_chat_window(player)
      return
    elsif npc.id.between?(32275, 32277)
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld)
        unless world.oracle_triggered[npc.id - 32275]
          return "no.htm" # TODO: Missing HTML.
        end
        npc.show_chat_window(player)
        return
      end
    elsif npc.id == 32274
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld)
        return "no.htm" # TODO: Missing HTML.
      end
    elsif npc.id == 32279
      st = player.get_quest_state(Q00131_BirdInACage.simple_name)
      return st && !st.completed? ? "32279-01.htm" : "32279.htm"
    elsif npc.id == CRYSTALLINE_GOLEM
      player.action_failed
    end

    ""
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if targets.includes?(npc)
      return super
    end

    case skill.id
    when 1011, 1015, 1217, 1218, 1401, 2360, 2369, 5146
      # proceed
    else
      return super
    end

    if npc.id.between?(32275, 32277) && skill.id != 2360 && skill.id != 2369
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld) && Rnd.rand(100) < 15
        world.oracles.each_key do |oracle|
          if oracle != npc
            oracle.decay_me
          end
        end
        world.oracle_triggered[npc.id - 32275] = true
      end
    elsif npc.invul? && npc.id == BAYLOR && skill.id == 2360 && caster
      unless caster.party
        return super
      end
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld)
        if world.dragon_claw_start + DRAGON_CLAW_TIME <= Time.ms || world.dragon_claw_need <= 0
          world.dragon_claw_start = Time.ms
          world.dragon_claw_need = caster.party.not_nil!.size - 1
        else
          world.dragon_claw_need &-= 1
        end
        if world.dragon_claw_need == 0
          npc.stop_skill_effects(false, 5225)
          npc.broadcast_packet(MagicSkillUse.new(npc, npc, 5480, 1, 4000, 0))
          if world.raid_status == 3
            world.raid_status &+= 1
          end
        end
      end
    elsif npc.invul? && npc.id == TEARS && skill.id == 2369 && caster
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld)
        if caster.party.nil?
          return super
        elsif world.dragon_scale_start + DRAGON_SCALE_TIME <= Time.ms || world.dragon_scale_needed <= 0
          world.dragon_scale_start = Time.ms
          world.dragon_scale_needed = caster.party.not_nil!.size - 1
        else
          world.dragon_scale_needed &-= 1
        end
        if world.dragon_scale_needed == 0 && Rnd.rand(100) < 80
          npc.invul = false
        end
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    if npc.id == TEARS
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld)
        if world.status != 4 && attacker
          # Lucky cheater, the code only kicks his/her ass out of the dungeon
          teleport_player(attacker, Location.new(149361, 172327, -945), 0)
          world.remove_allowed(attacker.l2id)
        elsif world.tears != npc
          return ""
        elsif !world.copies.empty?
          not_aoe = true
          if skill.nil? || !skill.aoe?
            not_aoe = false
          end
          if not_aoe
            world.copies.each do |copy|
              copy.on_decay
            end
            world.copies.clear
          end
          return ""
        end

        max_hp = npc.max_hp
        now_hp = npc.status.current_hp
        rand = Rnd.rand(1000)

        if now_hp < max_hp * 0.4 && rand < 5
          party = attacker.party
          if party
            party.members.each do |m|
              stop_attack(m)
            end
          else
            stop_attack(attacker)
          end
          target = npc.ai.attack_target
          10.times do
            copy = add_spawn(TEARS_COPY, *npc.xyz, 0, false, 0, false, attacker.instance_id)
            copy.set_running
            copy.as(L2Attackable).add_damage_hate(target, 0, 99999)
            copy.set_intention(AI::ATTACK, target)
            copy.current_hp = now_hp
            world.copies << copy
          end
        elsif now_hp < max_hp * 0.15 && !world.has_used_invul_skill
          if rand > 994 || now_hp < max_hp * 0.1
            world.has_used_invul_skill = true
            npc.invul = true
          end
        end
      end
    end

    nil
  end

  def on_spell_finished(npc, player, skill)
    if npc.id == BAYLOR && skill.id == 5225
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(CCWorld)
        world.raid_status &+= 1
      end
    end

    super
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!

    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(CCWorld)
      if event.casecmp?("TeleportOut")
        player = player.not_nil!
        teleport_player(player, Location.new(149413, 173078, -5014), 0)
      elsif event.casecmp?("TeleportParme")
        player = player.not_nil!
        teleport_player(player, Location.new(153689, 142226, -9750), world.instance_id)
      elsif event.matches?(/\ATimer[2-5]\z/i)
        player = player.not_nil!
        if player.instance_id == world.instance_id
          teleport_player(player, Location.new(144653, 152606, -12126), world.instance_id)
          player.stop_skill_effects(true, 5239)
          EVENT_TIMER_1.skill.apply_effects(player, player)
          start_quest_timer("Timer2", 300000, npc, player)
        end
      elsif event.matches?(/\ATimer[2-5]1\z/i)
        InstanceManager.get_instance(world.instance_id).not_nil!.remove_npcs
        world.npc_list_2.clear
        run_steam_rooms(world, STEAM1_SPAWNS, 22)
        start_quest_timer("Timer21", 300000, npc, nil)
      elsif event.casecmp?("checkKechiAttack")
        if npc.in_combat?
          start_quest_timer("spawnGuards", SPAWN[0], npc, nil)
          cancel_quest_timers("checkKechiAttack")
          close_door(DOOR4, npc.instance_id)
          close_door(DOOR3, npc.instance_id)
        else
          start_quest_timer("checkKechiAttack", 1000, npc, nil)
        end
      elsif event.casecmp?("spawnGuards")
        world.kechis_henchman_spawn &+= 1
        world.guards << add_spawn(KECHIS_HENCHMAN, 153622, 149699, -12131, 56890, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153609, 149622, -12131, 64023, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153606, 149428, -12131, 64541, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153601, 149534, -12131, 64901, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153620, 149354, -12131, 1164, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153637, 149776, -12131, 61733, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153638, 149292, -12131, 64071, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153647, 149857, -12131, 59402, false, 0, false, world.instance_id)
        world.guards << add_spawn(KECHIS_HENCHMAN, 153661, 149227, -12131, 65275, false, 0, false, world.instance_id)
        if world.kechis_henchman_spawn <= 5
          start_quest_timer("spawnGuards", SPAWN[world.kechis_henchman_spawn], npc, nil)
        else
          cancel_quest_timers("spawnGuards")
        end
      elsif event.casecmp?("EmeraldSteam")
        run_emerald(world)
        world.oracle.each &.decay_me
      elsif event.casecmp?("CoralGarden")
        run_coral(world)
        world.oracle.each &.decay_me
      elsif event.casecmp?("spawn_oracle")
        add_spawn(32271, 153572, 142075, -9728, 10800, false, 0, false, world.instance_id)
        add_spawn((Rnd.rand(10) < 5 ? 29116 : 29117), *npc.xyz, npc.heading, false, 0, false, world.instance_id) # Baylor's Chest
        add_spawn(ORACLE_GUIDE_4, 153572, 142075, -12738, 10800, false, 0, false, world.instance_id)
        cancel_quest_timer("baylor_despawn", npc, nil)
        cancel_quest_timers("baylor_skill")
      elsif event.casecmp?("baylorEffect0")
        npc.intention = AI::IDLE
        npc.broadcast_social_action(1)
        start_quest_timer("baylorCamera0", 11000, npc, nil)
        start_quest_timer("baylorEffect1", 19000, npc, nil)
      elsif event.casecmp?("baylorCamera0")
        npc.broadcast_packet(SpecialCamera.new(npc, 500, -45, 170, 5000, 9000, 0, 0, 1, 0, 0))
      elsif event.casecmp?("baylorEffect1")
        npc.broadcast_packet(SpecialCamera.new(npc, 300, 0, 120, 2000, 5000, 0, 0, 1, 0, 0))
        npc.broadcast_social_action(3)
        start_quest_timer("baylorEffect2", 4000, npc, nil)
      elsif event.casecmp?("baylorEffect2")
        npc.broadcast_packet(SpecialCamera.new(npc, 747, 0, 160, 2000, 3000, 0, 0, 1, 0, 0))
        npc.broadcast_packet(MagicSkillUse.new(npc, npc, 5402, 1, 2000, 0))
        start_quest_timer("RaidStart", 2000, npc, nil)
      elsif event.casecmp?("BaylorMinions")
        10.times do |i|
          radius = 300
          x = (radius * Math.cos(i * 0.618)).to_i
          y = (radius * Math.sin(i * 0.618)).to_i
          mob = add_spawn(29104, 153571 + x, 142075 + y, -12737, 0, false, 0, false, world.instance_id)
          mob.intention = AI::IDLE
          world.animation_mobs << mob
        end
        start_quest_timer("baylorEffect0", 200, npc, nil)
      elsif event.casecmp?("RaidStart")
        world.camera.decay_me
        world.camera = nil
        npc.paralyzed = false
        world.raiders.each do |p|
          p.paralyzed = false
          throw(npc, p)
          if summon = p.summon
            throw(npc, summon)
          end
        end
        world.raid_status = 0
        world.animation_mobs.each do |mob|
          mob.do_die(mob)
        end
        world.animation_mobs.clear
        start_quest_timer("baylor_despawn", 60000, npc, nil, true)
        start_quest_timer("checkBaylorAttack", 1000, npc, nil)
      elsif event.casecmp?("checkBaylorAttack")
        if npc.in_combat?
          cancel_quest_timers("checkBaylorAttack")
          start_quest_timer("baylor_alarm", 40000, npc, nil)
          start_quest_timer("baylor_skill", 5000, npc, nil, true)
          world.raid_status &+= 1
        else
          start_quest_timer("checkBaylorAttack", 1000, npc, nil)
        end
      elsif event.casecmp?("baylor_alarm")
        if world.alarm?.nil?
          spawn_loc = ALARM_SPAWN.sample(random: Rnd)
          npc.add_skill(PHYSICAL_UP.skill)
          npc.add_skill(MAGICAL_UP.skill)
          world.alarm = add_spawn(ALARM, spawn_loc[0], spawn_loc[1], spawn_loc[2], 10800, false, 0, false, world.instance_id)
          world.alarm.disable_core_ai(true)
          world.alarm.immobilized = true
          world.alarm.broadcast_packet(CreatureSay.new(world.alarm.l2id, 1, world.alarm.name, NpcString::AN_ALARM_HAS_BEEN_SET_OFF_EVERYBODY_WILL_BE_IN_DANGER_IF_THEY_ARE_NOT_TAKEN_CARE_OF_IMMEDIATELY))
        end
      elsif event.casecmp?("baylor_skill")
        if world.baylor?.nil?
          cancel_quest_timers("baylor_skill")
        else
          max_hp = npc.max_hp
          now_hp = npc.status.current_hp
          rand = Rnd.rand(100)

          if now_hp < max_hp * 0.2 && world.raid_status < 3 && !npc.affected_by_skill?(5224) && !npc.affected_by_skill?(5225)
            if now_hp < max_hp * 0.15 && world.raid_status == 2
              npc.do_cast(INVINCIBLE)
              npc.broadcast_packet(CreatureSay.new(npc.l2id, 1, npc.name, NpcString::DEMON_KING_BELETH_GIVE_ME_THE_POWER_AAAHH))
            elsif rand < 10 || now_hp < max_hp * 0.15
              npc.do_cast(INVINCIBLE)
              npc.broadcast_packet(CreatureSay.new(npc.l2id, 1, npc.name, NpcString::DEMON_KING_BELETH_GIVE_ME_THE_POWER_AAAHH))
              start_quest_timer("baylor_remove_invul", 30000, world.baylor, nil)
            end
          elsif now_hp < max_hp * 0.3 && rand > 50 && !npc.affected_by_skill?(5225) && !npc.affected_by_skill?(5224)
            npc.do_cast(BERSERK)
          elsif rand < 33
            npc.target = world.raiders.sample(random: Rnd)
            npc.do_cast(STRONG_PUNCH)
          end
        end
      elsif event.casecmp?("baylor_remove_invul")
        npc.stop_skill_effects(false, 5225)
      elsif event.casecmp?("Baylor")
        world.baylor = add_spawn(29099, 153572, 142075, -12738, 10800, false, 0, false, world.instance_id)
        world.baylor.paralyzed = true
        world.camera = add_spawn(29120, 153273, 141400, -12738, 10800, false, 0, false, world.instance_id)
        world.camera.broadcast_packet(SpecialCamera.new(world.camera, 700, -45, 160, 500, 15200, 0, 0, 1, 0, 0))
        start_quest_timer("baylorMinions", 2000, world.baylor, nil)
      elsif !event.ends_with?("Food")
        return ""
      elsif event.casecmp?("autoFood")
        unless world.crystal_golems.has_key?(npc)
          world.crystal_golems[npc] = CrystalGolem.new
        end
        if world.status != 3 || !world.crystal_golems.has_key?(npc) || world.crystal_golems[npc].food_item? || world.crystal_golems[npc].at_destination?
          return ""
        end

        cry_golem = world.crystal_golems[npc]
        min_dist = 300000
        L2World.get_visible_objects(npc, 300) do |object|
          if object.is_a?(L2ItemInstance) && object.id == CRYSTAL_FRAGMENT
            dx = npc.x - object.x
            dy = npc.y - object.y
            d = (dx * dx) + (dy * dy)
            if d < min_dist
              min_dist = d
              cry_golem.food_item = object
            end
          end
        end

        if min_dist != 300000
          start_quest_timer("getFood", 2000, npc, nil)
        else
          if Rnd.rand(100) < 5
            npc.broadcast_packet(CreatureSay.new(npc.l2id, 1, npc.name, NpcString::AH_IM_HUNGRY))
          end
          start_quest_timer("autoFood", 2000, npc, nil)
        end
        return ""
      elsif !world.crystal_golems.has_key?(npc) || world.crystal_golems[npc].at_destination?
        return ""
      elsif event.casecmp?("backFood")
        if npc.intention == AI::ACTIVE
          cancel_quest_timers("backFood")
          npc.set_intention(AI::IDLE, nil)
          world.crystal_golems[npc].food_item = nil
          start_quest_timer("autoFood", 2000, npc, nil)
        end
      elsif event.casecmp?("reachFood")
        cry_golem = world.crystal_golems[npc]
        if cry_golem.food_item?.nil? || !cry_golem.food_item.visible?
          npc.set_intention(AI::MOVE_TO, cry_golem.old_loc)
          cancel_quest_timers("reachFood")
          start_quest_timer("backFood", 2000, npc, nil, true)
          return ""
        elsif npc.intention == AI::ACTIVE
          L2World.remove_visible_object(cry_golem.food_item, cry_golem.food_item.world_region)
          L2World.remove_object(cry_golem.food_item)
          npc.set_intention(AI::IDLE, nil)
          cry_golem.food_item = nil
          dx = npc.x - 142999
          dy = npc.y - 151671
          d1 = (dx * dx) + (dy * dy)
          dx = npc.x - 139494
          dy = npc.y - 151668
          d2 = (dx * dx) + (dy * dy)
          if d1 < 10000 || d2 < 10000
            npc.broadcast_packet(MagicSkillUse.new(npc, npc, 5441, 1, 1, 0))
            cry_golem.at_destination = true
            world.correct_golems &+= 1
            if world.correct_golems >= 2
              open_door(24220026, world.instance_id)
              world.status = 4
            end
          else
            start_quest_timer("autoFood", 2000, npc, nil)
          end
          cancel_quest_timers("reachFood")
        end
        return ""
      elsif event.casecmp?("getFood")
        cry_golem = world.crystal_golems[npc]
        new_loc = Location.new(*cry_golem.food_item.xyz, 0)
        cry_golem.old_loc = Location.new(*npc.xyz, npc.heading)
        npc.set_intention(AI::MOVE_TO, new_loc)
        start_quest_timer("reachFood", 2000, npc, nil, true)
        cancel_quest_timers("getFood")
      end
    end

    ""
  end

  private def give_rewards(player, instance_id, boss_cry, is_baylor)
    num = Math.max(Config.rate_death_drop_chance_multiplier, 1).to_i

    party = player.party
    if party
      party.members.each do |m|
        if m.instance_id == instance_id
          if !is_baylor && has_quest_items?(m, CONTAMINATED_CRYSTAL)
            take_items(m, CONTAMINATED_CRYSTAL, 1)
            give_items(m, boss_cry, 1)
          end
          if Rnd.rand(10) < 5
            give_items(m, WHITE_SEED_OF_EVIL_SHARD, num)
          else
            give_items(m, BLACK_SEED_OF_EVIL_SHARD, num)
          end
        end
      end
    elsif player.instance_id == instance_id
      if !is_baylor && has_quest_items?(player, CONTAMINATED_CRYSTAL)
        take_items(player, CONTAMINATED_CRYSTAL, 1)
        give_items(player, boss_cry, 1)
      end
      if Rnd.rand(10) < 5
        give_items(player, WHITE_SEED_OF_EVIL_SHARD, num)
      else
        give_items(player, BLACK_SEED_OF_EVIL_SHARD, num)
      end
    end
  end

  def on_kill(npc, player, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(CCWorld)
      if world.status == 2 && world.npc_list1.has_key?(npc)
        world.npc_list1[npc] = true
        world.npc_list1.each_value do |is_dead|
          unless is_dead
            return ""
          end
        end
        world.status = 3
        world.tears = add_spawn(TEARS, 144298, 154420, -11854, 32767, false, 0, false, world.instance_id) # Tears
        cry_golem1 = CrystalGolem.new
        cry_golem2 = CrystalGolem.new
        world.crystal_golems[add_spawn(CRYSTALLINE_GOLEM, 140547, 151670, -11813, 32767, false, 0, false, world.instance_id)] = cry_golem1
        world.crystal_golems[add_spawn(CRYSTALLINE_GOLEM, 141941, 151684, -11813, 63371, false, 0, false, world.instance_id)] = cry_golem2
        world.crystal_golems.each_key do |cry_golem|
          start_quest_timer("autoFood", 2000, cry_golem, nil)
        end
      elsif world.status == 4 && npc.id == TEARS
        InstanceManager.get_instance(world.instance_id).not_nil!.duration = 300000
        add_spawn(32280, 144312, 154420, -11855, 0, false, 0, false, world.instance_id)
        give_rewards(player, npc.instance_id, CLEAR_CRYSTAL, false)
      elsif world.status == 2 && world.key_keepers.includes?(npc)
        if npc.id == GATEKEEPER_LOHAN
          npc.drop_item(player, 9698, 1)
          run_emerald_square(world)
        elsif npc.id == GATEKEEPER_PROVO
          npc.drop_item(player, 9699, 1)
          run_steam_rooms(world, STEAM1_SPAWNS, 22)
          if party = player.party
            party.members.each do |m|
              if m.instance_id == world.instance_id
                EVENT_TIMER_1.skill.apply_effects(m, m)
                start_quest_timer("Timer2", 300000, npc, m)
              end
            end
          else
            EVENT_TIMER_1.skill.apply_effects(player, player)
            start_quest_timer("Timer2", 300000, npc, player)
          end
          start_quest_timer("Timer21", 300000, npc, nil)
        end
        world.key_keepers.each do |gk|
          if gk != npc
            gk.decay_me
          end
        end
      elsif world.status == 3
        if check_kill_progress(0, npc, world)
          world.status = 4
          add_spawn(TOURMALINE, 148202, 144791, -12235, 0, false, 0, false, world.instance_id)
        else
          return ""
        end
      elsif world.status == 4
        if npc.id == TOURMALINE
          world.status = 5
          add_spawn(TEROD, 147777, 146780, -12281, 0, false, 0, false, world.instance_id)
        end
      elsif world.status == 5
        if npc.id == TEROD
          world.status = 6
          add_spawn(TOURMALINE, 143694, 142659, -11882, 0, false, 0, false, world.instance_id)
        end
      elsif world.status == 6
        if npc.id == TOURMALINE
          world.status = 7
          add_spawn(DOLPH, 142054, 143288, -11825, 0, false, 0, false, world.instance_id)
        end
      elsif world.status == 7
        if npc.id == DOLPH
          world.status = 8
          # first door opener trap
          trap = add_trap(DOOR_OPENING_TRAP[0], DOOR_OPENING_TRAP[1], DOOR_OPENING_TRAP[2], DOOR_OPENING_TRAP[3], DOOR_OPENING_TRAP[4], nil, world.instance_id)
          broadcast_npc_say(trap, Say2::NPC_SHOUT, NpcString::YOU_HAVE_FINALLY_COME_HERE_BUT_YOU_WILL_NOT_BE_ABLE_TO_FIND_THE_SECRET_ROOM)
        end
      elsif world.status == 8
        4.times do |i|
          if world.room_status[i] == 1 && check_kill_progress(i &+ 1, npc, world)
            world.room_status[i] = 2
          end
          if world.room_status[i] == 2
            world.cleaned_rooms &+= 1
            if world.cleaned_rooms == 21
              run_darnel(world)
            end
          end
        end
      elsif world.status >= 22 && world.status <= 25
        if npc.id == 22416
          world.oracles.each do |oracle, val|
            if val == npc
              world.oracles[oracle] = nil
            end
          end
        end
        if check_kill_progress(0, npc, world)
          world.npc_list_2.clear
          case world.status
          when 22
            close_door(DOOR6, npc.instance_id)
            oracle_order = ORDER_ORACLE1
          when 23
            oracle_order = ORDER_ORACLE2
          when 24
            oracle_order = ORDER_ORACLE3
          when 25
            world.status = 26
            if party = player.party
              party.members.each do |m|
                m.stop_skill_effects(true, 5239)
              end
            end
            cancel_quest_timers("Timer5")
            cancel_quest_timers("Timer51")
            open_door(DOOR3, npc.instance_id)
            open_door(DOOR4, npc.instance_id)
            kechi = add_spawn(KECHI, 154069, 149525, -12158, 51165, false, 0, false, world.instance_id)
            start_quest_timer("checkKechiAttack", 1000, kechi, nil)
            return ""
          else
            warn { "CrystalCavern-SteamCorridor: status #{world.status} error. oracle_order not found in #{world.instance_id}" }
            return ""
          end
          run_steam_oracles(world, oracle_order)
        end
      elsif (world.status == 9 && npc.id == DARNEL) || (world.status == 26 && npc.id == KECHI)
        InstanceManager.get_instance(world.instance_id).not_nil!.duration = 300000
        if npc.id == KECHI
          boss_cry = RED_CRYSTAL
          cancel_quest_timers("spawnGuards")
          add_spawn(32280, 154077, 149527, -12159, 0, false, 0, false, world.instance_id)
        elsif npc.id == DARNEL
          boss_cry = BLUE_CRYSTAL
          add_spawn(32280, 152761, 145950, -12588, 0, false, 0, false, world.instance_id)
        else
          # something is wrong
          return ""
        end
        give_rewards(player, npc.instance_id, boss_cry, false)
      end
      if npc.id == ALARM
        world.baylor.remove_skill(PHYSICAL_UP.skill_id)
        world.baylor.remove_skill(MAGICAL_UP.skill_id)
        world.alarm = nil
        if world.baylor.max_hp * 0.3 < world.baylor.status.current_hp
          start_quest_timer("baylor_alarm", 40000, world.baylor, nil)
        end
      elsif npc.id == BAYLOR
        world.status = 31
        world.baylor = nil
        baylor_instance = InstanceManager.get_instance(npc.instance_id).not_nil!
        baylor_instance.duration = 300000
        start_quest_timer("spawn_oracle", 1000, npc, nil)
        give_rewards(player, npc.instance_id, -1, true)
      end
    end

    ""
  end

  def on_talk(npc, player)
    npc_id = npc.id
    get_quest_state(player, true)
    if npc_id == ORACLE_GUIDE_1
      enter_instance(player, CCWorld.new(Time.ms + 5400000), "CrystalCaverns.xml", TEMPLATE_ID)
      return ""
    end

    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(CCWorld)
      if npc_id == CRYSTALLINE_GOLEM
        # there's nothing here
      elsif npc.id.between?(32275, 32277) && world.oracle_triggered[npc.id - 32275]
        party = player.party
        do_teleport = true

        case npc.id
        when 32275
          if world.status == 22
            run_steam_rooms(world, STEAM2_SPAWNS, 23)
          end
          loc = Location.new(147529, 152587, -12169)
          cancel_quest_timers("Timer2")
          cancel_quest_timers("Timer21")
          if party
            party.members.each do |m|
              if m.instance_id == world.instance_id
                m.stop_skill_effects(true, 5239)
                EVENT_TIMER_2.skill.apply_effects(m, m)
                start_quest_timer("Timer3", 600000, npc, m)
              end
            end
          else
            player.stop_skill_effects(true, 5239)
            EVENT_TIMER_2.skill.apply_effects(player, player)
            start_quest_timer("Timer3", 600000, npc, player)
          end
          start_quest_timer("Timer31", 600000, npc, nil)
        when 32276
          if world.status == 23
            run_steam_rooms(world, STEAM3_SPAWNS, 24)
          end
          loc = Location.new(150194, 152610, -12169)
          cancel_quest_timers("Timer3")
          cancel_quest_timers("Timer31")
          if party
            party.members.each do |m|
              if m.instance_id == world.instance_id
                m.stop_skill_effects(true, 5239)
                EVENT_TIMER_4.skill.apply_effects(m, m)
                start_quest_timer("Timer4", 1200000, npc, m)
              end
            end
          else
            player.stop_skill_effects(true, 5239)
            EVENT_TIMER_4.skill.apply_effects(player, player)
            start_quest_timer("Timer4", 1200000, npc, player)
          end
          start_quest_timer("Timer41", 1200000, npc, nil)
        when 32277
          if world.status == 24
            run_steam_rooms(world, STEAM4_SPAWNS, 25)
          end
          loc = Location.new(149743, 149986, -12141)
          cancel_quest_timers("Timer4")
          cancel_quest_timers("Timer41")
          if party
            party.members.each do |m|
              if m.instance_id == world.instance_id
                m.stop_skill_effects(true, 5239)
                EVENT_TIMER_3.skill.apply_effects(m, m)
                start_quest_timer("Timer5", 900000, npc, m)
              end
            end
          else
            player.stop_skill_effects(true, 5239)
            EVENT_TIMER_3.skill.apply_effects(player, player)
            start_quest_timer("Timer5", 900000, npc, player)
          end
          start_quest_timer("Timer51", 900000, npc, nil)
        else
          # something is wrong
          do_teleport = false
        end
        if do_teleport && loc
          if !check_oracle_conditions(player)
            return ""
          elsif party
            party.members.each do |m|
              m.destroy_item_by_item_id("Quest", RED_CORAL, 1, player, true)
              teleport_player(m, loc, npc.instance_id)
            end
          else
            teleport_player(player, loc, npc.instance_id)
          end
        end
      elsif npc.id == ORACLE_GUIDE_3
        if world.status < 30 && check_baylor_conditions(player)
          world.raiders.clear
          if party = player.party
            party.members.each do |m|
              # rnd = Rnd.rand(100)
              # m.destroy_item_by_item_id("Quest", (rnd < 33 ? BOSS_CRYSTAL_1:(rnd < 67 ? BOSS_CRYSTAL_2:BOSS_CRYSTAL_3)), 1, m, true); Crystals are no longer beign cunsumed while entering to Baylor Lair.
              world.raiders << m
            end
          else
            world.raiders << player
          end
        else
          return ""
        end
        world.status = 30
        time = world.end_time - Time.ms
        baylor_instance = InstanceManager.get_instance(world.instance_id).not_nil!
        baylor_instance.duration = time.to_i

        radius = 150
        members = world.raiders.size
        world.raiders.each_with_index do |p, i|
          x = (radius * Math.cos((i &* 2 * Math::PI) / members)).to_i
          y = (radius * Math.sin((i &* 2 * Math::PI) / members)).to_i
          p.tele_to_location(Location.new(153571 + x, 142075 + y, -12737))
          if pet = p.summon
            pet.tele_to_location(Location.new(153571 + x, 142075 + y, -12737), true)
            pet.broadcast_packet(ValidateLocation.new(pet))
          end
          p.paralyzed = true
          p.broadcast_packet(ValidateLocation.new(p))
        end
        start_quest_timer("Baylor", 30000, npc, nil)
      elsif npc.id == ORACLE_GUIDE_4 && world.status == 31
        teleport_player(player, Location.new(153522, 144212, -9747), npc.instance_id)
      end
    end

    ""
  end

  def on_trap_action(trap, trigger, action)
    world = InstanceManager.get_world(trap.instance_id)
    if world.is_a?(CCWorld)
      case action
      when TrapAction::DISARMED
        if trap.id == DOOR_OPENING_TRAP[0]
          open_door(24220001, world.instance_id)
          run_emerald_rooms(world, ROOM1_SPAWNS, 1)
        end
      end

    end

    nil
  end

  def on_enter_zone(character, zone)
    if character.is_a?(L2PcInstance)
      world = InstanceManager.get_world(character.instance_id)
      if world.is_a?(CCWorld)
        if world.status == 8
          case zone.id
          when 20105
            spawns = ROOM2_SPAWNS
            room = 2
          when 20106
            spawns = ROOM3_SPAWNS
            room = 3
          when 20107
            spawns = ROOM4_SPAWNS
            room = 4
          else
            return super
          end
          InstanceManager.get_instance(world.instance_id).not_nil!.doors.each do |door|
            if door.id == room + 24220000
              if door.open?
                return ""
              end

              unless has_quest_items?(character, SECRET_KEY)
                return ""
              end
              if world.room_status[zone.id &- 20104] == 0
                run_emerald_rooms(world, spawns, room)
              end
              door.open_me
              take_items(character, SECRET_KEY, 1)
              world.opened_doors[door] = character
              break
            end
          end
        end
      end
    end

    super
  end

  def on_exit_zone(character, zone)
    if character.is_a?(L2PcInstance)
      world = InstanceManager.get_world(character.instance_id)
      if world.is_a?(CCWorld)
        if world.status == 8
          case zone.id
          when 20105
            door_id = 24220002
          when 20106
            door_id = 24220003
          when 20107
            door_id = 24220004
          else
            return super
          end
        end
        InstanceManager.get_instance(world.instance_id).not_nil!.doors.each do |door|
          if door.id == door_id
            if door.open? && world.opened_doors[door] == character
              door.close_me
              world.opened_doors.delete(door)
            end
            break
          end
        end
      end
    end

    super
  end
end
