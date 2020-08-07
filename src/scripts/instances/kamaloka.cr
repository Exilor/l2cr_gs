class Scripts::Kamaloka < AbstractInstance
  RESET_HOUR = 6
  RESET_MIN = 30

  # Time after which instance without players will be destroyed Default: 5 minutes
  EMPTY_DESTROY_TIME = 5

  # Time to destroy instance (and eject players away) after boss defeat Default: 5 minutes
  EXIT_TIME = 5

  # Maximum level difference between players level and kamaloka level Default: 5
  MAX_LEVEL_DIFFERENCE = 5

  # If true shaman in the first room will have same npcId as other mobs, making radar useless Default: true (but not retail like)
  STEALTH_SHAMAN = true
  # Template IDs for Kamaloka
  TEMPLATE_IDS = [
    57, 58, 73, 60, 61, 74, 63, 64, 75, 66, 67, 76, 69, 70, 77, 72, 78, 79, 134
  ]
  # Level of the Kamaloka
  LEVEL = [
    23, 26, 29, 33, 36, 39, 43, 46, 49, 53, 56, 59, 63, 66, 69, 73, 78, 81, 83
  ]
  # Duration of the instance, minutes
  DURATION = [
    30, 30, 45, 30, 30, 45, 30, 30, 45, 30, 30, 45, 30, 30, 45, 30, 45, 45, 45
  ]
  # Maximum party size for the instance
  MAX_PARTY_SIZE = [
    6, 6, 9, 6, 6, 9, 6, 6, 9, 6, 6, 9, 6, 6, 9, 6, 9, 9, 9
  ]

  # List of buffs NOT removed on enter from player and pet<br>
  # On retail only newbie guide buffs not removed<br>
  # CAUTION: array must be sorted in ascension order!
  BUFFS_WHITELIST = [
    4322, 4323, 4324, 4325, 4326, 4327, 4328, 4329, 4330, 4331, 5632, 5637, 5950
  ]
  # Teleport points into instances x, y, z
  TELEPORTS = [
    Location.new(-88429, -220629, -7903),
    Location.new(-82464, -219532, -7899),
    Location.new(-10700, -174882, -10936), # -76280, -185540, -10936
    Location.new(-89683, -213573, -8106),
    Location.new(-81413, -213568, -8104),
    Location.new(-10700, -174882, -10936), # -76280, -174905, -10936
    Location.new(-89759, -206143, -8120),
    Location.new(-81415, -206078, -8107),
    Location.new(-10700, -174882, -10936),
    Location.new(-56999, -219856, -8117),
    Location.new(-48794, -220261, -8075),
    Location.new(-10700, -174882, -10936),
    Location.new(-56940, -212939, -8072),
    Location.new(-55566, -206139, -8120),
    Location.new(-10700, -174882, -10936),
    Location.new(-49805, -206139, -8117),
    Location.new(-10700, -174882, -10936),
    Location.new(-10700, -174882, -10936),
    Location.new(22003, -174886, -10900)
  ]

  # Respawn delay for the mobs in the first room, seconds Default: 25
  FIRST_ROOM_RESPAWN_DELAY = 25

  # First room information, nil if room not spawned.<br>
  # Skill is casted on the boss when shaman is defeated and mobs respawn stopped<br>
  # Default: 5699 (decrease pdef)<br>
  # shaman npcId, minions npcId, skillId, skillLvl
  FIRST_ROOM = [
    nil,
    nil,
    [
      22485,
      22486,
      5699,
      1
    ],
    nil,
    nil,
    [
      22488,
      22489,
      5699,
      2
    ],
    nil,
    nil,
    [
      22491,
      22492,
      5699,
      3
    ],
    nil,
    nil,
    [
      22494,
      22495,
      5699,
      4
    ],
    nil,
    nil,
    [
      22497,
      22498,
      5699,
      5
    ],
    nil,
    [
      22500,
      22501,
      5699,
      6
    ],
    [
      22503,
      22504,
      5699,
      7
    ],
    [
      25706,
      25707,
      5699,
      7
    ]
  ]

  # First room spawns, nil if room not spawned x, y, z
  FIRST_ROOM_SPAWNS = [
    nil,
    nil,
    [
      [
        -12381,
        -174973,
        -10955
      ],
      [
        -12413,
        -174905,
        -10955
      ],
      [
        -12377,
        -174838,
        -10953
      ],
      [
        -12316,
        -174903,
        -10953
      ],
      [
        -12326,
        -174786,
        -10953
      ],
      [
        -12330,
        -175024,
        -10953
      ],
      [
        -12211,
        -174900,
        -10955
      ],
      [
        -12238,
        -174849,
        -10953
      ],
      [
        -12233,
        -174954,
        -10953
      ]
    ],
    nil,
    nil,
    [
      [
        -12381,
        -174973,
        -10955
      ],
      [
        -12413,
        -174905,
        -10955
      ],
      [
        -12377,
        -174838,
        -10953
      ],
      [
        -12316,
        -174903,
        -10953
      ],
      [
        -12326,
        -174786,
        -10953
      ],
      [
        -12330,
        -175024,
        -10953
      ],
      [
        -12211,
        -174900,
        -10955
      ],
      [
        -12238,
        -174849,
        -10953
      ],
      [
        -12233,
        -174954,
        -10953
      ]
    ],
    nil,
    nil,
    [
      [
        -12381,
        -174973,
        -10955
      ],
      [
        -12413,
        -174905,
        -10955
      ],
      [
        -12377,
        -174838,
        -10953
      ],
      [
        -12316,
        -174903,
        -10953
      ],
      [
        -12326,
        -174786,
        -10953
      ],
      [
        -12330,
        -175024,
        -10953
      ],
      [
        -12211,
        -174900,
        -10955
      ],
      [
        -12238,
        -174849,
        -10953
      ],
      [
        -12233,
        -174954,
        -10953
      ]
    ],
    nil,
    nil,
    [
      [
        -12381,
        -174973,
        -10955
      ],
      [
        -12413,
        -174905,
        -10955
      ],
      [
        -12377,
        -174838,
        -10953
      ],
      [
        -12316,
        -174903,
        -10953
      ],
      [
        -12326,
        -174786,
        -10953
      ],
      [
        -12330,
        -175024,
        -10953
      ],
      [
        -12211,
        -174900,
        -10955
      ],
      [
        -12238,
        -174849,
        -10953
      ],
      [
        -12233,
        -174954,
        -10953
      ]
    ],
    nil,
    nil,
    [
      [
        -12381,
        -174973,
        -10955
      ],
      [
        -12413,
        -174905,
        -10955
      ],
      [
        -12377,
        -174838,
        -10953
      ],
      [
        -12316,
        -174903,
        -10953
      ],
      [
        -12326,
        -174786,
        -10953
      ],
      [
        -12330,
        -175024,
        -10953
      ],
      [
        -12211,
        -174900,
        -10955
      ],
      [
        -12238,
        -174849,
        -10953
      ],
      [
        -12233,
        -174954,
        -10953
      ]
    ],
    nil,
    [
      [
        -12381,
        -174973,
        -10955
      ],
      [
        -12413,
        -174905,
        -10955
      ],
      [
        -12377,
        -174838,
        -10953
      ],
      [
        -12316,
        -174903,
        -10953
      ],
      [
        -12326,
        -174786,
        -10953
      ],
      [
        -12330,
        -175024,
        -10953
      ],
      [
        -12211,
        -174900,
        -10955
      ],
      [
        -12238,
        -174849,
        -10953
      ],
      [
        -12233,
        -174954,
        -10953
      ]
    ],
    [
      [
        -12381,
        -174973,
        -10955
      ],
      [
        -12413,
        -174905,
        -10955
      ],
      [
        -12377,
        -174838,
        -10953
      ],
      [
        -12316,
        -174903,
        -10953
      ],
      [
        -12326,
        -174786,
        -10953
      ],
      [
        -12330,
        -175024,
        -10953
      ],
      [
        -12211,
        -174900,
        -10955
      ],
      [
        -12238,
        -174849,
        -10953
      ],
      [
        -12233,
        -174954,
        -10953
      ]
    ],
    [
      [
        20409,
        -174827,
        -10912
      ],
      [
        20409,
        -174947,
        -10912
      ],
      [
        20494,
        -174887,
        -10912
      ],
      [
        20494,
        -174767,
        -10912
      ],
      [
        20614,
        -174887,
        -10912
      ],
      [
        20579,
        -174827,
        -10912
      ],
      [
        20579,
        -174947,
        -10912
      ],
      [
        20494,
        -175007,
        -10912
      ],
      [
        20374,
        -174887,
        -10912
      ]
    ]
  ]

  # Second room information, nil if room not spawned Skill is casted on the
  # boss when all mobs are defeated Default: 5700 (decrease mdef) npcId,
  # skillId, skillLvl
  SECOND_ROOM = [
    nil,
    nil,
    [
      22487,
      5700,
      1
    ],
    nil,
    nil,
    [
      22490,
      5700,
      2
    ],
    nil,
    nil,
    [
      22493,
      5700,
      3
    ],
    nil,
    nil,
    [
      22496,
      5700,
      4
    ],
    nil,
    nil,
    [
      22499,
      5700,
      5
    ],
    nil,
    [
      22502,
      5700,
      6
    ],
    [
      22505,
      5700,
      7
    ],
    [
      25708,
      5700,
      7
    ]
  ]

  # Spawns for second room, nil if room not spawned x, y, z
  SECOND_ROOM_SPAWNS = [
    nil,
    nil,
    [
      [
        -14547,
        -174901,
        -10690
      ],
      [
        -14543,
        -175030,
        -10690
      ],
      [
        -14668,
        -174900,
        -10690
      ],
      [
        -14538,
        -174774,
        -10690
      ],
      [
        -14410,
        -174904,
        -10690
      ]
    ],
    nil,
    nil,
    [
      [
        -14547,
        -174901,
        -10690
      ],
      [
        -14543,
        -175030,
        -10690
      ],
      [
        -14668,
        -174900,
        -10690
      ],
      [
        -14538,
        -174774,
        -10690
      ],
      [
        -14410,
        -174904,
        -10690
      ]
    ],
    nil,
    nil,
    [
      [
        -14547,
        -174901,
        -10690
      ],
      [
        -14543,
        -175030,
        -10690
      ],
      [
        -14668,
        -174900,
        -10690
      ],
      [
        -14538,
        -174774,
        -10690
      ],
      [
        -14410,
        -174904,
        -10690
      ]
    ],
    nil,
    nil,
    [
      [
        -14547,
        -174901,
        -10690
      ],
      [
        -14543,
        -175030,
        -10690
      ],
      [
        -14668,
        -174900,
        -10690
      ],
      [
        -14538,
        -174774,
        -10690
      ],
      [
        -14410,
        -174904,
        -10690
      ]
    ],
    nil,
    nil,
    [
      [
        -14547,
        -174901,
        -10690
      ],
      [
        -14543,
        -175030,
        -10690
      ],
      [
        -14668,
        -174900,
        -10690
      ],
      [
        -14538,
        -174774,
        -10690
      ],
      [
        -14410,
        -174904,
        -10690
      ]
    ],
    nil,
    [
      [
        -14547,
        -174901,
        -10690
      ],
      [
        -14543,
        -175030,
        -10690
      ],
      [
        -14668,
        -174900,
        -10690
      ],
      [
        -14538,
        -174774,
        -10690
      ],
      [
        -14410,
        -174904,
        -10690
      ]
    ],
    [
      [
        -14547,
        -174901,
        -10690
      ],
      [
        -14543,
        -175030,
        -10690
      ],
      [
        -14668,
        -174900,
        -10690
      ],
      [
        -14538,
        -174774,
        -10690
      ],
      [
        -14410,
        -174904,
        -10690
      ]
    ],
    [
      [
        18175,
        -174991,
        -10653
      ],
      [
        18070,
        -174890,
        -10655
      ],
      [
        18157,
        -174886,
        -10655
      ],
      [
        18249,
        -174885,
        -10653
      ],
      [
        18144,
        -174821,
        -10648
      ]
    ]
  ]

  # miniboss info
  # skill is casted on the boss when miniboss is defeated
  # npcId, x, y, z, skill id, skill level
  # Miniboss information, nil if miniboss not spawned Skill is casted on the
  # boss when miniboss is defeated Default: 5701 (decrease patk) npcId, x, y,
  # z, skillId, skillLvl
  MINIBOSS = [
    nil,
    nil,
    [
      25616,
      -16874,
      -174900,
      -10427,
      5701,
      1
    ],
    nil,
    nil,
    [
      25617,
      -16874,
      -174900,
      -10427,
      5701,
      2
    ],
    nil,
    nil,
    [
      25618,
      -16874,
      -174900,
      -10427,
      5701,
      3
    ],
    nil,
    nil,
    [
      25619,
      -16874,
      -174900,
      -10427,
      5701,
      4
    ],
    nil,
    nil,
    [
      25620,
      -16874,
      -174900,
      -10427,
      5701,
      5
    ],
    nil,
    [
      25621,
      -16874,
      -174900,
      -10427,
      5701,
      6
    ],
    [
      25622,
      -16874,
      -174900,
      -10427,
      5701,
      7
    ],
    [
      25709,
      15828,
      -174885,
      -10384,
      5701,
      7
    ]
  ]

  # Bosses of the kamaloka Instance ends when boss is defeated npcId, x, y, z
  BOSS = [
    [
      18554,
      -88998,
      -220077,
      -7892
    ],
    [
      18555,
      -81891,
      -220078,
      -7893
    ],
    [
      29129,
      -20659,
      -174903,
      -9983
    ],
    [
      18558,
      -89183,
      -213564,
      -8100
    ],
    [
      18559,
      -81937,
      -213566,
      -8100
    ],
    [
      29132,
      -20659,
      -174903,
      -9983
    ],
    [
      18562,
      -89054,
      -206144,
      -8115
    ],
    [
      18564,
      -81937,
      -206077,
      -8100
    ],
    [
      29135,
      -20659,
      -174903,
      -9983
    ],
    [
      18566,
      -56281,
      -219859,
      -8115
    ],
    [
      18568,
      -49336,
      -220260,
      -8068
    ],
    [
      29138,
      -20659,
      -174903,
      -9983
    ],
    [
      18571,
      -56415,
      -212939,
      -8068
    ],
    [
      18573,
      -56281,
      -206140,
      -8115
    ],
    [
      29141,
      -20659,
      -174903,
      -9983
    ],
    [
      18577,
      -49084,
      -206140,
      -8115
    ],
    [
      29144,
      -20659,
      -174903,
      -9983
    ],
    [
      29147,
      -20659,
      -174903,
      -9983
    ],
    [
      25710,
      12047,
      -174887,
      -9944
    ]
  ]

  # Escape telepoters spawns, nil if not spawned x, y, z
  TELEPORTERS = [
    nil,
    nil,
    [
      -10865,
      -174905,
      -10944
    ],
    nil,
    nil,
    [
      -10865,
      -174905,
      -10944
    ],
    nil,
    nil,
    [
      -10865,
      -174905,
      -10944
    ],
    nil,
    nil,
    [
      -10865,
      -174905,
      -10944
    ],
    nil,
    nil,
    [
      -10865,
      -174905,
      -10944
    ],
    nil,
    [
      -10865,
      -174905,
      -10944
    ],
    [
      -10865,
      -174905,
      -10944
    ],
    [
      21837,
      -174885,
      -10904
    ]
  ]

  TELEPORTER = 32496

  CAPTAINS = [
    30332,
    30071,
    30916,
    30196,
    31981,
    31340
  ]

  private class KWorld < InstanceWorld
    property index : Int32 = 0  # 0-18 index of the kama type in arrays
    property shaman : Int32 = 0 # l2id of the shaman
    property! first_room : Array(L2Spawn)? # list of the spawns in the first room (excluding shaman)
    property! second_room : Array(Int32)? # list of l2ids mobs in the second room
    property mini_boss : Int32 = 0 # l2id of the miniboss
    property boss : L2Npc? # L2Npc - boss
  end

  def initialize
    super("Kamaloka")

    add_first_talk_id(TELEPORTER)
    add_talk_id(TELEPORTER)
    CAPTAINS.each do |cap|
      add_start_npc(cap)
      add_talk_id(cap)
    end
    FIRST_ROOM.each do |mob|
      if mob
        if STEALTH_SHAMAN
          add_kill_id(mob[1])
        else
          add_kill_id(mob[0])
        end
      end
    end

    SECOND_ROOM.each do |mob|
      if mob
        add_kill_id(mob[0])
      end
    end

    MINIBOSS.each do |mob|
      if mob
        add_kill_id(mob[0])
      end
    end

    BOSS.each do |mob|
      add_kill_id(mob[0])
    end
  end

  # Check if party with player as leader allowed to enter
  # @param player party leader
  # @param index (0-18) index of the kamaloka in arrays
  # @return true if party allowed to enter
  private def check_party_conditions(player, index)
    # player must be in party
    unless party = player.party
      player.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end
    # ...and be party leader
    if party.leader != player
      player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end
    # party must not exceed max size for selected instance
    if party.size > MAX_PARTY_SIZE[index]
      player.send_packet(SystemMessageId::PARTY_EXCEEDED_THE_LIMIT_CANT_ENTER)
      return false
    end

    # get level of the instance
    level = LEVEL[index]
    # and client name
    instance_name = InstanceManager.get_instance_id_name(TEMPLATE_IDS[index])

    # for each party member
    party.members.each do |m|
      # player level must be in range
      if (m.level &- level).abs > MAX_LEVEL_DIFFERENCE
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        player.send_packet(sm)
        return false
      end
      # player must be near party leader
      unless m.inside_radius?(player, 1000, true, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        player.send_packet(sm)
        return false
      end
      # get instances reenter times for player
      instance_times = InstanceManager.get_all_instance_times(m.l2id)
      if instance_times
        instance_times.each_key do |id|
          # find instance with same name (kamaloka or labyrinth)
          # TODO: Don't use instance name, use other system.
          unless instance_name == InstanceManager.get_instance_id_name(id)
            next
          end
          # if found instance still can"t be reentered - exit
          if Time.ms < instance_times[id]
            sm = SystemMessage.c1_may_not_re_enter_yet
            sm.add_pc_name(m)
            player.send_packet(sm)
            return false
          end
        end
      end
    end

    true
  end

  # Removing all buffs from player and pet except BUFFS_WHITELIST
  # @param ch player
  private def remove_buffs(ch)
    remove_buffs_impl(ch)
    if s = ch.summon
      remove_buffs_impl(s)
    end
  end

  private def remove_buffs_impl(ch)
    ch.effect_list.for_each(false) do |info|
      if !info.skill.stay_after_death? && BUFFS_WHITELIST.bincludes?(info.skill.id)
        info.effected.effect_list.stop_skill_effects(true, info.skill)
        true
      else
        false
      end
    end
  end

  # Handling enter of the players into kamaloka
  # @param player party leader
  # @param index (0-18) kamaloka index in arrays
  private def enter_instance(player, index)
    template_id = TEMPLATE_IDS[index]

    # check for existing instances for this player
    world = InstanceManager.get_player_world(player)
    # player already in the instance
    if world
      # but not in kamaloka
      if !world.is_a?(KWorld) || world.template_id != template_id
        player.send_packet(SystemMessageId::YOU_HAVE_ENTERED_ANOTHER_INSTANT_ZONE_THEREFORE_YOU_CANNOT_ENTER_CORRESPONDING_DUNGEON)
        return
      end
      # check for level difference again on reenter
      if (player.level - LEVEL[world.index]).abs > MAX_LEVEL_DIFFERENCE
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(player)
        player.send_packet(sm)
        return
      end
      # check what instance still exist
      if inst = InstanceManager.get_instance(world.instance_id)
        remove_buffs(player)
        teleport_player(player, TELEPORTS[index], world.instance_id)
      end
      return
    end
    # Creating new kamaloka instance
    unless check_party_conditions(player, index)
      return
    end

    # Creating dynamic instance without template
    instance_id = InstanceManager.create_dynamic_instance(nil)
    inst = InstanceManager.get_instance(instance_id).not_nil!
    # set name for the kamaloka
    inst.name = InstanceManager.get_instance_id_name(template_id)
    # set return location
    inst.exit_loc = Location.new(player)
    # disable summon friend into instance
    inst.allow_summon = false
    # set duration and empty destroy time
    inst.duration = DURATION[index] * 60000
    inst.empty_destroy_time = EMPTY_DESTROY_TIME.to_i64 * 60000

    # Creating new instanceWorld, using our instance_id and template_id
    world = KWorld.new
    world.instance_id = instance_id
    world.template_id = template_id
    # set index for easy access to the arrays
    world.index = index
    InstanceManager.add_world(world)
    world.status = 0
    # spawn npcs
    spawn_kama(world)

    # and finally teleport party into instance
    player.party.not_nil!.members.each do |m|
      world.add_allowed(m.l2id)
      remove_buffs(m)
      teleport_player(m, TELEPORTS[index], instance_id)
    end

    nil
  end

  # Called on instance finish and handles reenter time for instance
  # @param world instanceWorld
  def finish_instance(world)
    if world.is_a?(KWorld)
      reenter = Calendar.new
      reenter.minute = RESET_MIN
      # if time is >= RESET_HOUR - roll to the next day
      if reenter.hour >= RESET_HOUR
        reenter.add(1.day)
      end
      reenter.hour = RESET_HOUR

      sm = SystemMessage.instant_zone_from_here_s1_s_entry_has_been_restricted
      sm.add_instance_name(world.template_id)

      # set instance reenter time for all allowed players
      world.allowed.each do |l2id|
        obj = L2World.get_player(l2id)
        if obj && obj.online?
          InstanceManager.set_instance_time(l2id, world.template_id, reenter.ms)
          obj.send_packet(sm)
        end
      end

      # destroy instance after EXIT_TIME
      inst = InstanceManager.get_instance(world.instance_id).not_nil!
      inst.duration = EXIT_TIME * 60000
      inst.empty_destroy_time = 0
    end
  end

  # Spawn all NPCs in kamaloka
  # @param world instanceWorld
  private def spawn_kama(world)
    index = world.index

    # first room
    npcs = FIRST_ROOM[index]?
    spawns = FIRST_ROOM_SPAWNS[index]?
    if npcs && spawns
      world.first_room = Array(L2Spawn).new(spawns.size - 1)
      shaman = Rnd.rand(spawns.size) # random position for shaman

      spawns.size.times do |i|
        if i == shaman
          # stealth shaman use same npcId as other mobs
          npc = add_spawn(STEALTH_SHAMAN ? npcs[1] : npcs[0], spawns[i][0], spawns[i][1], spawns[i][2], 0, false, 0, false, world.instance_id)
          world.shaman = npc.l2id
        else
          npc = add_spawn(npcs[1], spawns[i][0], spawns[i][1], spawns[i][2], 0, false, 0, false, world.instance_id)
          sp = npc.spawn
          sp.respawn_delay = FIRST_ROOM_RESPAWN_DELAY
          sp.amount = 1
          sp.start_respawn
          world.first_room << sp # store mobs spawns
        end
        npc.no_random_walk = true
      end
    end

    # second room
    npcs = SECOND_ROOM[index]?
    spawns = SECOND_ROOM_SPAWNS[index]?
    if npcs && spawns
      world.second_room = Array(Int32).new(spawns.size)

      spawns.each do |sp|
        npc = add_spawn(npcs[0], sp[0], sp[1], sp[2], 0, false, 0, false, world.instance_id)
        npc.no_random_walk = true
        world.second_room << npc.l2id
      end
    end

    # miniboss
    if tmp = MINIBOSS[index]?
      npc = add_spawn(tmp[0], tmp[1], tmp[2], tmp[3], 0, false, 0, false, world.instance_id)
      npc.no_random_walk = true
      world.mini_boss = npc.l2id
    end

    # escape teleporter
    if tmp = TELEPORTERS[index]?
      add_spawn(TELEPORTER, tmp[0], tmp[1], tmp[2], 0, false, 0, false, world.instance_id)
    end

    # boss
    npc = add_spawn(BOSS[index][0], BOSS[index][1], BOSS[index][2], BOSS[index][3], 0, false, 0, false, world.instance_id)
    npc.as(L2MonsterInstance).on_kill_delay = 100
    world.boss = npc
  end

  # Handles only player's enter, single parameter - integer kamaloka index
  def on_adv_event(event, npc, player)
    if npc && player
      enter_instance(player, event.to_i)
    end

    ""
  end

  def on_talk(npc, player)
    if npc.id == TELEPORTER
      party = player.party
      # only party leader can talk with escape teleporter
      if party && party.leader?(player)
        world = InstanceManager.get_world(npc.instance_id)
        if world.is_a?(KWorld)
          # party members must be in the instance
          if world.allowed?(player.l2id)
            inst = InstanceManager.get_instance(world.instance_id).not_nil!

            # teleports entire party away
            party.members.each do |m|
              if m.instance_id == world.instance_id
                teleport_player(m, inst.exit_loc.not_nil!, 0)
              end
            end
          end
        end
      end
    else
      return "#{npc.id}.htm"
    end

    ""
  end

  def on_first_talk(npc, player)
    if npc.id == TELEPORTER
      if (party = player.party) && party.leader?(player)
        return "32496.htm"
      end

      return "32496-no.htm"
    end

    ""
  end

  def on_kill(npc, player, is_summon)
    world = InstanceManager.get_world(npc.instance_id).as(KWorld)
    l2id = npc.l2id

    # first room was spawned ?
    if world.first_room?
      # is shaman killed ?
      if world.shaman != 0 && world.shaman == l2id
        world.shaman = 0
        # stop respawn of the minions
        world.first_room.each &.try &.stop_respawn
        world.first_room.clear
        world.first_room = nil

        if boss = world.boss
          skill_id = FIRST_ROOM[world.index].not_nil![2]
          skill_lvl = FIRST_ROOM[world.index].not_nil![3]
          if skill_id != 0 && skill_lvl != 0
            if skill = SkillData[skill_id, skill_lvl]?
              skill.apply_effects(boss, boss)
            end
          end
        end
      end

      return super
    end

    # second room was spawned ?
    if world.second_room?
      all = true
      # check for all mobs in the second room
      world.second_room.size.times do |i|
        # found killed now mob
        tmp = world.second_room[i]
        if tmp == l2id
          tmp = 0
        elsif tmp != 0
          all = false
        end
      end
      # all mobs killed ?
      if all
        world.second_room.clear
        world.second_room = nil

        if boss = world.boss
          skill_id = SECOND_ROOM[world.index].not_nil![1]
          skill_lvl = SECOND_ROOM[world.index].not_nil![2]
          if skill_id != 0 && skill_lvl != 0
            if skill = SkillData[skill_id, skill_lvl]?
              skill.apply_effects(boss, boss)
            end
          end
        end

        return super
      end
    end

    # miniboss spawned ?
    if world.mini_boss != 0 && world.mini_boss == l2id
      world.mini_boss = 0

      if boss = world.boss
        skill_id = MINIBOSS[world.index].not_nil![4]
        skill_lvl = MINIBOSS[world.index].not_nil![5]
        if skill_id != 0 && skill_lvl != 0
          if skill = SkillData[skill_id, skill_lvl]?
            skill.apply_effects(boss, boss)
          end
        end
      end

      return super
    end

    # boss was killed, finish instance
    boss = world.boss
    if boss && boss == npc
      world.boss = nil
      finish_instance(world)
    end

    super
  end

  def on_enter_instance(pc, world, first_entrance)
    # no-op
  end
end
