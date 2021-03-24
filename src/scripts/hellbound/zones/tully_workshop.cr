class Scripts::TullyWorkshop < AbstractNpcAI
  # NPCs
  private AGENT = 32372
  private CUBE_68 = 32467
  private DORIAN = 32373
  private DARION = 25603
  private TULLY = 25544
  private DWARVEN_GHOST = 32370
  private TOMBSTONE = 32344
  private INGENIOUS_CONTRAPTION = 32371
  private PILLAR = 18506
  # private BRIDGE_CONTROLLER = 32468
  private TIMETWISTER_GOLEM = 22392
  private SIN_WARDENS = {
    22423,
    22431
  }
  private SERVANT_FIRST = 22405
  private SERVANT_LAST = 22410
  private TEMENIR = 25600
  private DRAXIUS = 25601
  private KIRETCENAH = 25602

  # Skills
  private CHALLENGERS_BLESSING = SkillHolder.new(5526)
  private NPC_HEAL = SkillHolder.new(4065, 11)

  # Items
  private REWARDS = {
    10427,
    10428,
    10429,
    10430,
    10431
  }

  # 7 for 6th floor and 10 for 8th floor
  private DEATH_COUNTS = {
    7,
    10
  }

  private STATE_OPEN = 0
  private STATE_CLOSE = 1

  # Them are teleporting players to themselves
  # Master Zelos - 22377, Zelos' Minions - 22378, 22379, Tully's Toy - 22383
  private TELEPORTING_MONSTERS = {
    22377,
    22378,
    22379,
    22383
  }

  private TULLY_DOORLIST = {
    18445 => [19260001, 19260002],
    18446 => [19260003],
    18447 => [19260003, 19260004, 19260005],
    18448 => [19260006, 19260007],
    18449 => [19260007, 19260008],
    18450 => [19260010],
    18451 => [19260011, 19260012],
    18452 => [19260009, 19260011],
    18453 => [19260014, 19260023, 19260013],
    18454 => [19260015, 19260023],
    18455 => [19260016],
    18456 => [19260017, 19260018],
    18457 => [19260021, 19260020],
    18458 => [19260022],
    18459 => [19260018],
    18460 => [19260051],
    18461 => [19260052],
    99999 => [19260019]
  }
  private TELE_COORDS = {
    32753 => {
      Location.new(-12700, 273340, -13600),
      Location.new(0, 0, 0)
    },
    32754 => {
      Location.new(-13246, 275740, -11936),
      Location.new(-12894, 273900, -15296)
    },
    32755 => {
      Location.new(-12798, 273458, -10496),
      Location.new(-12718, 273490, -13600)
    },
    32756 => {
      Location.new(-13500, 275912, -9032),
      Location.new(-13246, 275740, -11936)
    }
  }

  # NPC's, spawned after Tully's death are stored here
  private POSTMORTEM_SPAWNS = [] of L2Npc
  private BROKEN_CONTRAPTIONS = Set(Int32).new
  private REWARDED_CONTRAPTIONS = Set(Int32).new
  private TALKED_CONTRAPTIONS = Set(Int32).new
  private SPAWNED_FOLLOWERS = [] of L2MonsterInstance
  private SPAWNED_FOLLOWER_MINIONS = [] of L2MonsterInstance
  private DEATH_COUNT = Slice.new(2) { Slice.new(4, 0) }

  # They are spawned after Tully's Death. Format: npc_id, x, y, z, heading, despawn_time
  private POST_MORTEM_SPAWNLIST = {
    [32371, -12524, 273932, -9014,  49151, 0], # Ingenious Contraption
    [32371, -10831, 273890, -9040,  81895, 0], # Ingenious Contraption
    [32371, -10817, 273986, -9040, -16452, 0], # Ingenious Contraption
    [32371, -13773, 275119, -9040,   8428, 49151, 0], # Ingenious Contraption
    [32371, -11547, 271772, -9040, -19124, 0], # Ingenious Contraption
    [22392, -10832, 273808, -9040,      0, 0], # Failed Experimental Timetwister Golem
    [22392, -10816, 274096, -9040,  14964, 0], # Failed Experimental Timetwister Golem
    [22392, -13824, 275072, -9040, -24644, 0], # Failed Experimental Timetwister Golem
    [22392, -11504, 271952, -9040,   9328, 0], # Failed Experimental Timetwister Golem
    [22392, -11680, 275353, -9040,      0, 0], # Failed Experimental Timetwister Golem
    [22392, -12388, 271668, -9040,      0, 0], # Failed Experimental Timetwister Golem
    [32370, -11984, 272928, -9040,  23644, 900000], # Old Dwarven Ghost
    [32370, -14643, 274588, -9040,  49152, 0], # Old Dwarven Ghost
    [32344, -14756, 274788, -9040, -13868, 0]  # Spooky Tombstone
  }

  # Format: npc_id, x, y, z, heading
  private SPAWNLIST_7TH_FLOOR = {
    {25602, -12528, 279488, -11622,  16384},
    {25600, -12736, 279681, -11622,      0},
    {25601, -12324, 279681, -11622,  32768},
    {25599, -12281, 281497, -11935,  49151},
    {25599, -11903, 281488, -11934,  49151},
    {25599, -11966, 277935, -11936,  16384},
    {25599, -12334, 277935, -11936,  16384},
    {25599, -12739, 277935, -11936,  16384},
    {25599, -13063, 277934, -11936,  16384},
    {25599, -13077, 281506, -11935,  49151},
    {25599, -12738, 281503, -11935,  49151},
    {25597, -11599, 281323, -11933, -23808},
    {25597, -11381, 281114, -11934, -23808},
    {25597, -11089, 280819, -11934, -23808},
    {25597, -10818, 280556, -11934, -23808},
    {25597, -10903, 278798, -11934,  25680},
    {25597, -11134, 278558, -11934,  25680},
    {25597, -11413, 278265, -11934,  25680},
    {25597, -11588, 278072, -11935,  25680},
    {25597, -13357, 278058, -11935,   9068},
    {25597, -13617, 278289, -11935,   9068},
    {25597, -13920, 278567, -11935,   9068},
    {25597, -14131, 278778, -11936,   9068},
    {25597, -14184, 280545, -11936,  -7548},
    {25597, -13946, 280792, -11936,  -7548},
    {25597, -13626, 281105, -11936,  -7548},
    {25597, -13386, 281360, -11935,  -7548},
    {25598, -10697, 280244, -11936,  32768},
    {25598, -10702, 279926, -11936,  32768},
    {25598, -10722, 279470, -11936,  32768},
    {25598, -10731, 279126, -11936,  32768},
    {25598, -14284, 279140, -11936,      0},
    {25598, -14286, 279464, -11936,      0},
    {25598, -14290, 279909, -11935,      0},
    {25598, -14281, 280229, -11936,      0}
  }

  # Zone ID's for rooms
  private SPAWN_ZONE_DEF = {
    {200012, 200013, 200014, 200015}, # 6th floor
    {200016, 200017, 200018, 200019}  # 8th floor
  }

  private AGENT_COORDINATES = {
    {-13312, 279172, -13599, -20300}, # 6th floor room 1
    {-11696, 280208, -13599,  13244}, # 6th floor room 2
    {-13008, 280496, -13599,  27480}, # 6th floor room 3
    {-11984, 278880, -13599,  -4472}, # 6th floor room 4
    {-13312, 279172, -10492, -20300}, # 8th floor room 1
    {-11696, 280208, -10492,  13244}, # 8th floor room 2
    {-13008, 280496, -10492,  27480}, # 8th floor room 3
    {-11984, 278880, -10492,  -4472}  # 8th floor room 4
  }

  private SERVANT_COORDINATES = {
    {-13214, 278493, -13601, 0}, # 6th floor room 1
    {-11727, 280711, -13601, 0}, # 6th floor room 2
    {-13562, 280175, -13601, 0}, # 6th floor room 3
    {-11514, 278592, -13601, 0}, # 6th floor room 4
    {-13370, 278459, -10497, 0}, # 8th floor room 1
    {-11984, 280894, -10497, 0}, # 8th floor room 2
    {-14050, 280312, -10497, 0}, # 8th floor room 3
    {-11559, 278725, -10495, 0}  # 8th floor room 4
  }

  private CUBE_68_TELEPORTS = {
    {-12176, 279696, -13596}, # to 6th floor
    {-12176, 279696, -10492}, # to 8th floor
    { 21935, 243923,  11088}  # to roof
  }

  @countdown_time = 0
  @next_servant_idx = 0
  @killed_followers_count = 0
  @allow_servant_spawn = true
  @allow_agent_spawn = true
  @allow_agent_spawn_7th = true
  @has_7th_floor_attack_began = false
  @countdown : TaskScheduler::PeriodicTask?
  @spawned_agent : L2Npc?
  @pillar_spawn : L2Spawn?

  def initialize
    super(self.class.simple_name, "hellbound/AI/Zones")

    add_start_npc(DORIAN)
    add_talk_id(DORIAN)

    TULLY_DOORLIST.each_key do |npc_id|
      if npc_id != 99999
        add_first_talk_id(npc_id)
        add_start_npc(npc_id)
        add_talk_id(npc_id)
      end
    end

    TELE_COORDS.each_key do |npc_id|
      add_start_npc(npc_id)
      add_talk_id(npc_id)
    end

    TELEPORTING_MONSTERS.each do |monster_id|
      add_attack_id(monster_id)
    end

    SIN_WARDENS.each do |monster_id|
      add_kill_id(monster_id)
    end

    add_start_npc(AGENT)
    add_start_npc(CUBE_68)
    add_start_npc(INGENIOUS_CONTRAPTION)
    add_start_npc(DWARVEN_GHOST)
    add_start_npc(TOMBSTONE)
    add_talk_id(AGENT)
    add_talk_id(CUBE_68)
    add_talk_id(INGENIOUS_CONTRAPTION)
    add_talk_id(DWARVEN_GHOST)
    add_talk_id(DWARVEN_GHOST)
    add_talk_id(TOMBSTONE)
    add_first_talk_id(AGENT)
    add_first_talk_id(CUBE_68)
    add_first_talk_id(INGENIOUS_CONTRAPTION)
    add_first_talk_id(DWARVEN_GHOST)
    add_first_talk_id(TOMBSTONE)
    add_kill_id(TULLY)
    add_kill_id(TIMETWISTER_GOLEM)
    add_kill_id(TEMENIR)
    add_kill_id(DRAXIUS)
    add_kill_id(KIRETCENAH)
    add_kill_id(DARION)
    add_kill_id(PILLAR)
    add_faction_call_id(TEMENIR)
    add_faction_call_id(DRAXIUS)
    add_faction_call_id(KIRETCENAH)

    add_spawn_id(CUBE_68)
    add_spawn_id(DARION)
    add_spawn_id(TULLY)
    add_spawn_id(PILLAR)
    add_spell_finished_id(AGENT)
    add_spell_finished_id(TEMENIR)

    SERVANT_FIRST.upto(SERVANT_LAST) do |i|
      add_kill_id(i)
      add_spell_finished_id(i)
    end

    init_death_counter(0)
    init_death_counter(1)
    do_7th_floor_spawn
    do_on_load_spawn
  end

  def on_first_talk(npc, player)
    class_id = player.class_id
    npc_id = npc.id

    if TULLY_DOORLIST.has_key?(npc_id)
      if class_id.maestro?
        return "doorman-01c.htm"
      end
      return "doorman-01.htm"
    elsif npc_id == INGENIOUS_CONTRAPTION
      if TALKED_CONTRAPTIONS.includes?(npc.l2id)
        return "32371-02.htm"
      elsif !BROKEN_CONTRAPTIONS.includes?(npc.l2id)
        if class_id.maestro?
          return "32371-01a.htm"
        end
        return "32371-01.htm"
      end
      return "32371-04.htm"
    elsif npc_id == DWARVEN_GHOST
      if POSTMORTEM_SPAWNS.index(npc) == 11
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HA_HA_YOU_WERE_SO_AFRAID_OF_DEATH_LET_ME_SEE_IF_YOU_FIND_ME_IN_TIME_MAYBE_YOU_CAN_FIND_A_WAY)
        npc.delete_me
        return
      elsif POSTMORTEM_SPAWNS.index(npc) == 12
        return "32370-01.htm"
      elsif npc.inside_radius?(-45531, 245872, -14192, 100, true, false) # Hello from Tower of Naia! :) Due to onFirstTalk limitation it should be here
        return "32370-03.htm"
      else
        return "32370-02.htm"
      end
    elsif npc_id == AGENT
      party = player.party
      if party.nil? || party.leader_l2id != player.l2id
        return "32372-01a.htm"
      end

      room_data = get_room_data(npc)
      if room_data[0] < 0 || room_data[1] < 0
        return "32372-02.htm"
      end
      return "32372-01.htm"
    elsif npc_id == CUBE_68
      if npc.inside_radius?(-12752, 279696, -13596, 100, true, false)
        return "32467-01.htm"
      elsif npc.inside_radius?(-12752, 279696, -10492, 100, true, false)
        return "32467-02.htm"
      end
      return "32467-03.htm"
    elsif npc_id == TOMBSTONE
      REWARDS.each do |item_id|
        if has_at_least_one_quest_item?(player, item_id)
          return "32344-01.htm"
        end
      end
      return "32344-01a.htm"
    end

    nil
  end

  def on_talk(npc, player)
    if npc.id == TOMBSTONE
      unless party = player.party
        return "32344-03.htm"
      end

      has_items = Slice.new(5, false)

      # For teleportation party should have all 5 medals
      party.members.each do |pl|
        REWARDS.each_with_index do |e, i|
          if pl.inventory.get_inventory_item_count(e, -1, false) > 0
            if Util.in_range?(300, pl, npc, true)
              has_items[i] = true
              break
            end
          end
        end
      end

      medals_count = has_items.count &.itself

      if medals_count == 0
        return "32344-03.htm"
      elsif medals_count < 5
        return "32344-02.htm"
      end

      party.members.each do |pl|
        if Util.in_range?(6000, pl, npc, false)
          pl.tele_to_location(26612, 248567, -2856)
        end
      end
    end

    super
  end

  def on_adv_event(event, npc, player)
    html = event

    if event.casecmp?("disable_zone")
      if dmg_zone = ZoneManager.get_zone_by_id(200011)
        dmg_zone.enabled = false
      end
    elsif event.casecmp?("cube_68_spawn")
      spawned_npc = add_spawn(CUBE_68, 12527, 279714, -11622, 16384, false, 0, false)
      start_quest_timer("cube_68_despawn", 600_000, spawned_npc, nil)
    elsif event.casecmp?("end_7th_floor_attack")
      do_7th_floor_despawn
    elsif event.casecmp?("start_7th_floor_spawn")
      do_7th_floor_spawn
    end

    unless npc
      return
    end

    npc_id = npc.id
    if event.casecmp?("close") && TULLY_DOORLIST.has_key?(npc_id)
      # Second instance of 18455
      if npc_id == 18455 && npc.x == -14610
        npc_id = 99999
      end

      doors = TULLY_DOORLIST[npc_id]
      doors.each do |door_id|
        DoorData.get_door!(door_id).close_me
      end
    end

    if event.casecmp?("repair_device")
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::DE_ACTIVATE_THE_ALARM)
      BROKEN_CONTRAPTIONS.delete(npc.l2id)
    elsif event.casecmp?("despawn_servant") && npc.alive?
      if !npc.intention.attack? && !npc.intention.cast? && npc.current_hp == npc.max_hp
        npc.delete_me
        @allow_servant_spawn = true
      else
        start_quest_timer("despawn_servant", 180_000, npc, nil)
      end
    elsif event.casecmp?("despawn_agent")
      npc.delete_me
      @allow_servant_spawn = true
      @allow_agent_spawn = true
    elsif event.casecmp?("despawn_agent_7")
      npc.known_list.get_known_players_in_radius(300) do |pl|
        pl.tele_to_location(-12176, 279696, -10492, true)
      end

      @allow_agent_spawn_7th = true
      @spawned_agent = nil
      npc.delete_me
    elsif event.casecmp?("cube_68_despawn")
      npc.known_list.get_known_players_in_radius(500) do |pl|
        pl.tele_to_location(-12176, 279696, -10492, true)
      end

      npc.delete_me
      start_quest_timer("start_7th_floor_spawn", 120000, nil, nil)
    end

    unless player
      return
    end

    if event.casecmp?("enter") && npc_id == DORIAN
      party = player.party

      if party && party.leader_l2id == player.l2id
        party.members.each do |m|
          unless Util.in_range?(300, m, npc, true)
            return "32373-02.htm"
          end
        end

        party.members.each &.tele_to_location(-13400, 272827, -15300, true)
        html = nil
      else
        html = "32373-02a.htm"
      end
    elsif event.casecmp?("open") && TULLY_DOORLIST.has_key?(npc_id)
      # Second instance of 18455
      if npc_id == 18455 && npc.x == -14610
        npc_id = 99999
      end

      TULLY_DOORLIST[npc_id].each do |door_id|
        DoorData.get_door!(door_id).open_me
      end

      start_quest_timer("close", 120_000, npc, nil)
      html = nil
    elsif event.matches?(/\Aup|down\z/i) && TELE_COORDS.has_key?(npc_id)
      direction = event.casecmp?("up") ? 0 : 1
      party = player.party
      if party.nil?
        player.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      elsif party.leader_l2id != player.l2id
        player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      elsif !Util.in_range?(4000, player, npc, true)
        player.send_packet(SystemMessageId::TOO_FAR_FROM_NPC)
      else
        loc = TELE_COORDS.dig(npc_id, direction)
        party.members.each do |m|
          if Util.in_range?(4000, m, npc, true)
            m.tele_to_location(loc, true)
          end
        end
      end
      html = nil
    elsif npc_id == INGENIOUS_CONTRAPTION
      if event.casecmp?("touch_device")
        i0 = TALKED_CONTRAPTIONS.includes?(npc.l2id) ? 0 : 1
        i1 = player.class_id.maestro? ? 6 : 3

        if Rnd.rand(1000) < (i1 - i0) * 100
          TALKED_CONTRAPTIONS << npc.l2id
          html = player.class_id.maestro? ? "32371-03a.htm" : "32371-03.htm"
        else
          BROKEN_CONTRAPTIONS << npc.l2id
          start_quest_timer("repair_device", 60_000, npc, nil)
          html = "32371-04.htm"
        end
      elsif event.casecmp?("take_reward")
        already_has_item = REWARDS.any? do |item_id|
          player.inventory.get_inventory_item_count(item_id, -1, false) > 0
        end

        if !already_has_item && !REWARDED_CONTRAPTIONS.includes?(npc.l2id)
          idx = POSTMORTEM_SPAWNS.index(npc) || -1
          if idx > -1 && idx < 5
            player.add_item("Quest", REWARDS[idx], 1, npc, true)
            REWARDED_CONTRAPTIONS << npc.l2id
            if idx != 0
              npc.delete_me
            end
          end
          html = nil
        else
          html = "32371-05.htm"
        end
      end
    elsif npc_id == AGENT
      if event.casecmp?("tele_to_7th_floor") && @allow_agent_spawn == false
        html = nil
        party = player.party
        if party.nil?
          player.tele_to_location(-12501, 281397, -11936)
          if @allow_agent_spawn_7th
            if tmp = @spawned_agent
              tmp.delete_me
            end
            @spawned_agent = add_spawn(AGENT, -12527, 279714, -11622, 16384, false, 0, false)
            @allow_agent_spawn_7th = false
          end
        else
          if party.leader_l2id != player.l2id
            player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
          else
            party.members.each do |m|
              if Util.in_range?(6000, m, npc, true)
                m.tele_to_location(-12501, 281397, -11936, true)
              end
            end

            if @allow_agent_spawn_7th
              if tmp = @spawned_agent
                tmp.delete_me
              end
              @spawned_agent = add_spawn(AGENT, -12527, 279714, -11622, 16384, false, 0, false)
              @allow_agent_spawn_7th = false
            end
          end
        end
      elsif event.casecmp?("buff") && !@allow_agent_spawn_7th
        html = nil
        party = player.party
        if party.nil?
          if !Util.in_range?(400, player, npc, true)
            html = "32372-01b.htm"
          else
            npc.target = player
          end
          npc.do_cast(CHALLENGERS_BLESSING)
        else
          party.members.each do |m|
            unless Util.in_range?(400, m, npc, true)
              return "32372-01b.htm"
            end
          end

          party.members.each do |m|
            npc.target = m
            npc.do_cast(CHALLENGERS_BLESSING)
          end
          start_quest_timer("despawn_agent_7", 60_000, npc, nil)
        end
      elsif event.casecmp?("refuse") && !@allow_agent_spawn_7th
        @allow_agent_spawn_7th = true
        npc.delete_me
        @spawned_agent = nil

        SPAWNED_FOLLOWERS.each do |monster|
          if monster.alive?
            unless monster.has_minions?
              MinionList.spawn_minion(monster, 25596)
              MinionList.spawn_minion(monster, 25596)
            end

            if party = player.party
              target = party.members.sample(random: Rnd)
            else
              target = player
            end

            if target.alive?
              monster.add_damage_hate(target, 0, 999)
              monster.set_intention(AI::ATTACK, target)
            end
          end
        end

        unless @has_7th_floor_attack_began
          @has_7th_floor_attack_began = true
          start_quest_timer("end_7th_floor_attack", 1_200_000, nil, nil)
        end
      end
    elsif event.casecmp?("teleport") && npc_id == DWARVEN_GHOST
      html = nil
      party = player.party
      if party.nil?
        player.tele_to_location(-12176, 279696, -13596)
      else
        if party.leader_l2id != player.l2id
          player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
          return
        end

        party.members.each do |m|
          unless Util.in_range?(3000, m, npc, true)
            return "32370-01f.htm"
          end
        end

        party.members.each do |m|
          if Util.in_range?(6000, m, npc, true)
            m.tele_to_location(-12176, 279696, -13596, true)
          end
        end
      end
    elsif npc_id == CUBE_68 && event.starts_with?("cube68_tp")
      html = nil
      tp_id = event.from(10).to_i

      if party = player.party
        if !party.leader?(player)
          player.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
        elsif !Util.in_range?(3000, player, npc, true)
          html = "32467-04.htm"
        else
          party.members.each do |m|
            if Util.in_range?(6000, m, npc, true)
              m.tele_to_location(*CUBE_68_TELEPORTS[tp_id], true)
            end
          end
        end
      else
        player.tele_to_location(*CUBE_68_TELEPORTS[tp_id])
      end
    end

    html
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    npc_id = npc.id
    if TELEPORTING_MONSTERS.bincludes?(npc_id)
      if (npc.z - attacker.z).abs > 150
        npc.as(L2MonsterInstance).clear_aggro_list
        attacker.tele_to_location(npc.x + 50, npc.y - 50, npc.z)
      end
    elsif npc_id == TEMENIR || npc_id == KIRETCENAH
      if SPAWNED_FOLLOWERS.includes?(npc)
        victim1 = SPAWNED_FOLLOWERS[1] # TEMENIR
        victim2 = SPAWNED_FOLLOWERS[0] # KIRETCENAH
        actor = SPAWNED_FOLLOWERS[2] # DRAXIUS

        if actor && actor.alive?
          transf_hp = actor.max_hp * 0.0001
          if Rnd.rand(10_000) > 1500 && victim1 && victim1.alive?
            if actor.current_hp - transf_hp > 1
              actor.current_hp -= transf_hp
              victim1.current_hp += transf_hp
            end
          end

          if Rnd.rand(10_000) > 3000 && victim2 && victim2.alive?
            if actor.current_hp - transf_hp > 1
              actor.current_hp -= transf_hp
              victim2.current_hp += transf_hp
            end
          end
        end
      end
    end

    if npc_id.in?(TEMENIR, DRAXIUS) && SPAWNED_FOLLOWERS.includes?(npc)
      victim = npc_id == TEMENIR ? SPAWNED_FOLLOWERS[1] : SPAWNED_FOLLOWERS[2]
      actor = SPAWNED_FOLLOWERS[0]

      if actor && victim && actor.alive? && victim.alive? && Rnd.rand(1000) > 333
        actor.clear_aggro_list
        actor.intention = AI::ACTIVE
        actor.target = victim
        actor.do_cast(NPC_HEAL)
        victim.current_hp += victim.max_hp * 0.03 # FIXME: not retail, it should be done after spell is finished, but it cannot be tracked now
      end
    end

    super
  end

  def on_faction_call(npc, caller, attacker, is_summon)
    case npc.id
    when TEMENIR, DRAXIUS, KIRETCENAH
      npc = npc.as(L2MonsterInstance)
      unless npc.has_minions?
        MinionList.spawn_minion(npc, 25596)
        MinionList.spawn_minion(npc, 25596)
      end

      unless @has_7th_floor_attack_began
        @has_7th_floor_attack_began = true
        start_quest_timer("end_7th_floor_attack", 1200000, nil, nil)

        if tmp = @spawned_agent
          tmp.delete_me
          @spawned_agent = nil
          @allow_agent_spawn_7th = true
        end
      end
    end


    super
  end

  def on_kill(npc, killer, is_summon)
    npc_id = npc.id

    if npc_id == TULLY && npc.inside_radius?(-12557, 273901, -9000, 1000, false, false)
      POST_MORTEM_SPAWNLIST.each do |i|
        tmp = add_spawn(i[0], i[1], i[2], i[3], i[4], false, i[5], false)
        POSTMORTEM_SPAWNS << tmp
      end

      DoorData.get_door!(19260051).open_me
      DoorData.get_door!(19260052).open_me

      @countdown_time = 600_000
      task = -> do
        @countdown_time &-= 10_000
        _npc = nil
        unless POSTMORTEM_SPAWNS.empty?
          _npc = POSTMORTEM_SPAWNS[0]
        end
        if @countdown_time > 60_000
          if @countdown_time % 60_000 == 0
            if _npc && _npc.id == INGENIOUS_CONTRAPTION
              broadcast_npc_say(_npc, Say2::NPC_SHOUT, NpcString::S1_MINUTES_REMAINING, @countdown_time // 60_000)
            end
          end
        elsif @countdown_time <= 0
          if countdown = @countdown
            countdown.cancel
            @countdown = nil
          end

          POSTMORTEM_SPAWNS.each do |tmp|
            if tmp.id == INGENIOUS_CONTRAPTION || tmp.id == TIMETWISTER_GOLEM
              tmp.delete_me
            end
          end

          BROKEN_CONTRAPTIONS.clear
          REWARDED_CONTRAPTIONS.clear
          TALKED_CONTRAPTIONS.clear

          if dmg_zone = ZoneManager.get_zone_by_id(200011)
            dmg_zone.enabled = true
          end
          start_quest_timer("disable_zone", 300_000, nil, nil)
        else
          if _npc && _npc.id == INGENIOUS_CONTRAPTION
            broadcast_npc_say(_npc, Say2::NPC_SHOUT, NpcString::S1_SECONDS_REMAINING, @countdown_time // 1000)
          end
        end
      end
      @countdown = ThreadPoolManager.schedule_general_at_fixed_rate(task, 60_000, 10_000)
      broadcast_npc_say(POSTMORTEM_SPAWNS[0], Say2::NPC_SHOUT, NpcString::DETONATOR_INITIALIZATION_TIME_S1_MINUTES_FROM_NOW, (@countdown_time / 60_000).to_i)
    elsif npc_id == TIMETWISTER_GOLEM && @countdown
      if Rnd.rand(1000) >= 700
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::A_FATAL_ERROR_HAS_OCCURRED)
        if @countdown_time > 180_000
          @countdown_time = Math.max(@countdown_time &- 180_000, 60_000)
          tmp = POSTMORTEM_SPAWNS[0]?
          if tmp && tmp.id == INGENIOUS_CONTRAPTION
            broadcast_npc_say(tmp, Say2::NPC_SHOUT, NpcString::ZZZZ_CITY_INTERFERENCE_ERROR_FORWARD_EFFECT_CREATED)
          end
        end
      else
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::TIME_RIFT_DEVICE_ACTIVATION_SUCCESSFUL)
        if @countdown_time > 0 && @countdown_time <= 420_000
          @countdown_time &+= 180_000
          tmp = POSTMORTEM_SPAWNS[0]?
          if tmp && tmp.id == INGENIOUS_CONTRAPTION
            broadcast_npc_say(tmp, Say2::NPC_SHOUT, NpcString::ZZZZ_CITY_INTERFERENCE_ERROR_RECURRENCE_EFFECT_CREATED)
          end
        end
      end
    elsif SIN_WARDENS.bincludes?(npc_id)
      room_data = get_room_data(npc)
      if room_data[0] >= 0 && room_data[1] >= 0
        DEATH_COUNT[room_data[0]][room_data[1]] += 1

        if @allow_servant_spawn
          max = 0
          floor = room_data[0]
          room = -1
          4.times do |i|
            if DEATH_COUNT[floor][i] > max
              max = DEATH_COUNT[floor][i]
              room = i
            end
          end

          if room >= 0 && max >= DEATH_COUNTS[floor]
            cf = floor == 1 ? 3 : 0
            servant_id = SERVANT_FIRST + @next_servant_idx &+ cf
            coords = SERVANT_COORDINATES[room + cf]
            spawned_npc = add_spawn(servant_id, coords[0], coords[1], coords[2], 0, false, 0, false)
            @allow_servant_spawn = false
            start_quest_timer("despawn_servant", 180_000, spawned_npc, nil)
          end
        end
      end
    elsif npc_id.between?(SERVANT_FIRST, SERVANT_LAST)
      room_data = get_room_data(npc)

      if room_data[0] >= 0 && room_data[1] >= 0 && @allow_agent_spawn
        @allow_servant_spawn = true
        if @next_servant_idx == 2
          @next_servant_idx = 0
          init_death_counter(room_data[0])
          if RaidBossSpawnManager.get_raid_boss_status_id(DARION).alive?
            @allow_agent_spawn = false
            @allow_servant_spawn = false
            cf = room_data[0] == 1 ? 3 : 0
            coords = AGENT_COORDINATES[room_data[1] &+ cf]
            spawned_npc = add_spawn(AGENT, coords[0], coords[1], coords[2], 0, false, 0, false)
            start_quest_timer("despawn_agent", 180_000, spawned_npc, nil)
          end
        else
          4.times do |i|
            if i == room_data[1]
              DEATH_COUNT[room_data[0]][i] = 0
            else
              DEATH_COUNT[room_data[0]][i] = (DEATH_COUNT[room_data[0]][i] + 1) * Rnd.rand(3)
            end
          end

          if Rnd.rand(1000) > 500
            @next_servant_idx += 1
          end
        end
      end

      if npc.id - 22404 == 3 || npc.id - 22404 == 6
        broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::I_FAILED_PLEASE_FORGIVE_ME_DARION)
      else
        broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::S1_ILL_BE_BACK_DONT_GET_COMFORTABLE, killer.name)
      end
    elsif npc_id.in?(TEMENIR, DRAXIUS, KIRETCENAH) && SPAWNED_FOLLOWERS.includes?(npc)
      @killed_followers_count &+= 1
      if @killed_followers_count >= 3
        do_7th_floor_despawn
      end
    elsif npc_id == DARION
      if pillar = @pillar_spawn
        if sp = pillar.last_spawn
          sp.invul = false
        else
          warn { "Last spawn for pillar #{pillar} is nil." }
        end
      end

      handle_doors_on_death
    elsif npc_id == PILLAR
      add_spawn(DWARVEN_GHOST, npc.x + 30, npc.y - 30, npc.z, 0, false, 900_000, false)
    end

    super
  end

  def on_spawn(npc)
    if npc.id == TULLY && npc.inside_radius?(-12557, 273901, -9000, 1000, true, false)
      POSTMORTEM_SPAWNS.each &.delete_me
      POSTMORTEM_SPAWNS.clear
    elsif npc.id == DARION
      if pillar = @pillar_spawn
        if sp = pillar.last_spawn
          sp.invul = false
        else
          warn { "Last spawn for pillar #{pillar} is nil." }
        end
      end
      handle_doors_on_respawn
    elsif npc.id == PILLAR
      npc.invul = RaidBossSpawnManager.get_raid_boss_status_id(DARION).alive?
    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    npc_id = npc.id
    skill_id = skill.id

    if npc_id == AGENT && skill_id == 5526
      pc.tele_to_location(21935, 243923, 11088, true) # to the roof
    elsif npc_id == TEMENIR && skill_id == 5331
      if npc.alive?
        npc.current_hp += npc.max_hp * 0.005
      end
    elsif npc_id >= SERVANT_FIRST && npc_id <= SERVANT_LAST && skill_id == 5392
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::S1_THANK_YOU_FOR_GIVING_ME_YOUR_LIFE, pc.name)
      dmg = pc.current_hp / (npc.id - 22404)
      pc.reduce_current_hp(dmg, nil, nil)
      npc.current_hp = (npc.current_hp + 10) - (npc.id - 22404)
    end

    super
  end

  private def get_room_data(npc)
    ret = {-1, -1}
    if npc
      sp = npc.spawn
      x = sp.x
      y = sp.y
      z = sp.z
      ZoneManager.get_zones(x, y, z) do |zone|
        2.times do |i|
          4.times do |j|
            if SPAWN_ZONE_DEF[i][j] == zone.id
              # ret[0] = i # 0 - 6th floor, 1 - 8th floor
              # ret[1] = j # room number: 0 == 1'st and so on
              ret = {i, j}
              return ret
            end
          end
        end
      end
    end

    ret
  end

  private def init_death_counter(floor)
    4.times { |i| DEATH_COUNT[floor][i] = Rnd.rand(DEATH_COUNTS[floor]) }
  end

  private def do_7th_floor_spawn
    @killed_followers_count = 0
    @has_7th_floor_attack_began = false

    SPAWNLIST_7TH_FLOOR.each do |data|
      monster = add_spawn(*data, false, 0, false).as(L2MonsterInstance)
      if data[0].in?(TEMENIR, DRAXIUS, KIRETCENAH)
        SPAWNED_FOLLOWERS << monster
      else
        SPAWNED_FOLLOWER_MINIONS << monster
      end
    end
  end

  private def do_7th_floor_despawn
    cancel_quest_timers("end_7th_floor_attack")
    SPAWNED_FOLLOWERS.each do |monster|
      if monster.alive?
        monster.delete_me
      end
    end

    SPAWNED_FOLLOWER_MINIONS.each do |monster|
      if monster.alive?
        monster.delete_me
      end
    end

    SPAWNED_FOLLOWERS.clear
    SPAWNED_FOLLOWER_MINIONS.clear
    start_quest_timer("cube_68_spawn", 60_000, nil, nil)
  end

  private def do_on_load_spawn
    # Ghost of Tully and Spooky Tombstone should be spawned, if Tully isn't alive
    unless RaidBossSpawnManager.get_raid_boss_status_id(TULLY).alive?
      12.upto(13) do |i|
        data = POST_MORTEM_SPAWNLIST[i].values_at(0, 1, 2, 3, 4)
        spawned_npc = add_spawn(*data, false, 0, false)
        POSTMORTEM_SPAWNS << spawned_npc
      end
    end

    # Pillar related
    sp = add_spawn(PILLAR, 21008, 244000, 11087, 0, false, 0, false).spawn
    sp.amount = 1
    sp.respawn_delay = 1200
    sp.start_respawn
    @pillar_spawn = sp

    # Doors related
    unless RaidBossSpawnManager.get_raid_boss_status_id(DARION).alive?
      handle_doors_on_death
    end

    # add_spawn(BRIDGE_CONTROLLER, 12527, 279714, -11622, 16384, false, 0, false)
  end

  private def handle_doors_on_death
    DoorData.get_door!(20250005).open_me
    DoorData.get_door!(20250004).open_me
    ThreadPoolManager.schedule_general(DoorTask.new({20250006, 20250007}, STATE_OPEN), 2000)
    ThreadPoolManager.schedule_general(DoorTask.new({20250778}, STATE_CLOSE), 3000)
    ThreadPoolManager.schedule_general(DoorTask.new({20250777}, STATE_CLOSE), 6000)
    ThreadPoolManager.schedule_general(DoorTask.new({20250009, 20250008}, STATE_OPEN), 11000)
  end

  private def handle_doors_on_respawn
    DoorData.get_door!(20250009).close_me
    DoorData.get_door!(20250008).close_me
    ThreadPoolManager.schedule_general(DoorTask.new({20250777, 20250778}, STATE_OPEN), 1000)
    ThreadPoolManager.schedule_general(DoorTask.new({20250005, 20250004, 20250006, 20250007}, STATE_CLOSE), 4000)
  end

  private struct DoorTask
    alias IDS_TYPE = {Int32} | {Int32, Int32} | {Int32, Int32, Int32, Int32}

    initializer door_ids : IDS_TYPE, state : Int32

    def call
      @door_ids.each do |door_id|
        if door = DoorData.get_door(door_id)
          case @state
          when STATE_OPEN
            door.open_me
          else # STATE_CLOSE
            door.close_me
          end
        end
      end
    end
  end
end
