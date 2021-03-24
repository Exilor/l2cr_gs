class Scripts::MonasteryOfSilence1 < AbstractInstance
  private class MOSWorld < InstanceWorld
    property dead_tomb_guardian_count = 0
    property dead_solina_guardian_count = 0
    property! elcadia : L2Npc
  end

  # NPCs
  private ELCADIA_INSTANCE = 32787
  private ERIS_EVIL_THOUGHTS = 32792
  private RELIC_GUARDIAN = 32803
  private RELIC_WATCHER1 = 32804
  private RELIC_WATCHER2 = 32805
  private RELIC_WATCHER3 = 32806
  private RELIC_WATCHER4 = 32807
  private ODD_GLOBE = 32815
  private TELEPORT_CONTROL_DEVICE1 = 32817
  private TELEPORT_CONTROL_DEVICE2 = 32818
  private TELEPORT_CONTROL_DEVICE3 = 32819
  private TELEPORT_CONTROL_DEVICE4 = 32820
  private TOMB_OF_THE_SAINTESS = 32843
  # Monsters
  private TRAINEE_OF_REST = 27403
  private SUPPLICANT_OF_REST = 27404
  private ETIS_VAN_ETINA = 18949
  private SOLINAS_GUARDIAN_1 = 18952
  private SOLINAS_GUARDIAN_2 = 18953
  private SOLINAS_GUARDIAN_3 = 18954
  private SOLINAS_GUARDIAN_4 = 18955
  private GUARDIAN_OF_THE_TOMB_1 = 18956
  private GUARDIAN_OF_THE_TOMB_2 = 18957
  private GUARDIAN_OF_THE_TOMB_3 = 18958
  private GUARDIAN_OF_THE_TOMB_4 = 18959
  # Items
  private SCROLL_OF_ABSTINENCE = 17228
  private SHIELD_OF_SACRIFICE = 17229
  private SWORD_OF_HOLY_SPIRIT = 17230
  private STAFF_OF_BLESSING = 17231
  # Skills
  private BUFFS = {
    SkillHolder.new(6725), # Bless the Blood of Elcadia
    SkillHolder.new(6728), # Recharge of Elcadia
    SkillHolder.new(6730)  # Greater Battle Heal of Elcadia
  }
  # Locations
  private START_LOC = Location.new(120717, -86879, -3424)
  private EXIT_LOC = Location.new(115983, -87351, -3397)
  private CENTRAL_ROOM_LOC = Location.new(85794, -249788, -8320)
  private SOUTH_WATCHERS_ROOM_LOC = Location.new(85798, -246566, -8320)
  private WEST_WATCHERS_ROOM_LOC = Location.new(82531, -249405, -8320)
  private EAST_WATCHERS_ROOM_LOC = Location.new(88665, -249784, -8320)
  private NORTH_WATCHERS_ROOM_LOC = Location.new(85792, -252336, -8320)
  private BACK_LOC = Location.new(120710, -86971, -3392)
  private START_LOC_Q10295 = Location.new(45545, -249423, -6788)
  private CASKET_ROOM_LOC = Location.new(56033, -252944, -6792)
  private SOLINAS_RESTING_PLACE_LOC = Location.new(55955, -250394, -6792)
  private DIRECTORS_ROOM_LOC = Location.new(120717, -86879, -3424)
  private GUARDIAN_OF_THE_TOMB_1_LOC = Location.new(55498, -252781, -6752, 0)
  private GUARDIAN_OF_THE_TOMB_2_LOC = Location.new(55520, -252160, -6752, 0)
  private GUARDIAN_OF_THE_TOMB_3_LOC = Location.new(56635, -252776, -6752, -32180)
  private GUARDIAN_OF_THE_TOMB_4_LOC = Location.new(56672, -252156, -6754, 32252)
  private SOLINAS_GUARDIAN_1_LOC = Location.new(45399, -253051, -6765, 16584)
  private SOLINAS_GUARDIAN_2_LOC = Location.new(48736, -249632, -6768, -32628)
  private SOLINAS_GUARDIAN_3_LOC = Location.new(45392, -246303, -6768, -16268)
  private SOLINAS_GUARDIAN_4_LOC = Location.new(42016, -249648, -6764, 0)
  private ELCADIA_LOC = Location.new(115927, -87005, -3392)
  private SPACE_LOC = Location.new(76736, -241021, -10780)
  private ETIS_VAN_ETINA_LOC = Location.new(76625, -240824, -10832, 0)
  private SLAVE_SPAWN_1_LOC = {
    Location.new(55680, -252832, -6752),
    Location.new(55825, -252792, -6752),
    Location.new(55687, -252718, -6752),
    Location.new(55824, -252679, -6752)
  }
  private SLAVE_SPAWN_2_LOC = {
    Location.new(55672, -252099, -6751),
    Location.new(55810, -252262, -6752),
    Location.new(55824, -252112, -6752),
    Location.new(55669, -252227, -6752)
  }
  private SLAVE_SPAWN_3_LOC = {
    Location.new(56480, -252833, -6751),
    Location.new(56481, -252725, -6752),
    Location.new(56368, -252787, -6752),
    Location.new(56368, -252669, -6752)
  }
  private SLAVE_SPAWN_4_LOC = {
    Location.new(56463, -252225, -6751),
    Location.new(56469, -252108, -6752),
    Location.new(56336, -252168, -6752),
    Location.new(56336, -252288, -6752)
  }
  # NpcString
  private ELCADIA_DIALOGS_Q010294 = {
    NpcString::WE_MUST_SEARCH_HIGH_AND_LOW_IN_EVERY_ROOM_FOR_THE_READING_DESK_THAT_CONTAINS_THE_BOOK_WE_SEEK,
    NpcString::REMEMBER_THE_CONTENT_OF_THE_BOOKS_THAT_YOU_FOUND_YOU_CANT_TAKE_THEM_OUT_WITH_YOU,
    NpcString::IT_SEEMS_THAT_YOU_CANNOT_REMEMBER_TO_THE_ROOM_OF_THE_WATCHER_WHO_FOUND_THE_BOOK
  }

  private ELCADIA_DIALOGS_Q010295 = {
    NpcString::THE_GUARDIAN_OF_THE_SEAL_DOESNT_SEEM_TO_GET_INJURED_AT_ALL_UNTIL_THE_BARRIER_IS_DESTROYED,
    NpcString::THE_DEVICE_LOCATED_IN_THE_ROOM_IN_FRONT_OF_THE_GUARDIAN_OF_THE_SEAL_IS_DEFINITELY_THE_BARRIER_THAT_CONTROLS_THE_GUARDIANS_POWER,
    NpcString::TO_REMOVE_THE_BARRIER_YOU_MUST_FIND_THE_RELICS_THAT_FIT_THE_BARRIER_AND_ACTIVATE_THE_DEVICE
  }
  # Misc
  private TEMPLATE_ID = 151
  # Doors
  private TOMB_DOOR = 21100018
  private DOORS = {
    21100014,
    21100001,
    21100006,
    21100010,
    21100003,
    21100008,
    21100012,
    21100016,
    21100002,
    21100015,
    21100005,
    21100004,
    21100009,
    21100007,
    21100013,
    21100011
  }

  private FAKE_TOMB_DOORS = {
    21100101,
    21100102,
    21100103,
    21100104
  }

  def initialize
    super(self.class.simple_name)

    add_first_talk_id(
      TELEPORT_CONTROL_DEVICE1, TELEPORT_CONTROL_DEVICE2,
      TELEPORT_CONTROL_DEVICE3, TELEPORT_CONTROL_DEVICE4
    )
    add_kill_id(
      SOLINAS_GUARDIAN_1, SOLINAS_GUARDIAN_2, SOLINAS_GUARDIAN_3,
      SOLINAS_GUARDIAN_4, GUARDIAN_OF_THE_TOMB_1, GUARDIAN_OF_THE_TOMB_2,
      GUARDIAN_OF_THE_TOMB_3, GUARDIAN_OF_THE_TOMB_4, ETIS_VAN_ETINA
    )
    add_spawn_id(ERIS_EVIL_THOUGHTS, TOMB_OF_THE_SAINTESS)
    add_start_npc(
      ODD_GLOBE, TELEPORT_CONTROL_DEVICE1, TELEPORT_CONTROL_DEVICE2,
      TELEPORT_CONTROL_DEVICE3, TELEPORT_CONTROL_DEVICE4, ERIS_EVIL_THOUGHTS
    )
    add_talk_id(
      ODD_GLOBE, ERIS_EVIL_THOUGHTS, RELIC_GUARDIAN, RELIC_WATCHER1,
      RELIC_WATCHER2, RELIC_WATCHER3, RELIC_WATCHER4, TELEPORT_CONTROL_DEVICE1,
      TELEPORT_CONTROL_DEVICE2, TELEPORT_CONTROL_DEVICE3,
      TELEPORT_CONTROL_DEVICE4, ERIS_EVIL_THOUGHTS
    )
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world.add_allowed(pc.l2id)
    end

    teleport_player(pc, START_LOC, world.instance_id, false)
    spawn_elcadia(pc, world.as(MOSWorld))
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!

    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(MOSWorld)
      case event
      when "TELE2"
        player = player.not_nil!
        teleport_player(player, CENTRAL_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(CENTRAL_ROOM_LOC, world.instance_id, 0)
        start_quest_timer("START_MOVIE", 2000, npc, player)
      when "EXIT"
        player = player.not_nil!
        cancel_quest_timer("FOLLOW", npc, player)
        cancel_quest_timer("DIALOG", npc, player)
        teleport_player(player, EXIT_LOC, 0)
        world.elcadia.delete_me
      when "START_MOVIE"
        player = player.not_nil!
        player.show_quest_movie(24)
      when "BACK"
        player = player.not_nil!
        teleport_player(player, BACK_LOC, world.instance_id)
        world.elcadia.tele_to_location(BACK_LOC, world.instance_id, 0)
      when "EAST"
        player = player.not_nil!
        teleport_player(player, EAST_WATCHERS_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(EAST_WATCHERS_ROOM_LOC, world.instance_id, 0)
      when "WEST"
        player = player.not_nil!
        teleport_player(player, WEST_WATCHERS_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(WEST_WATCHERS_ROOM_LOC, world.instance_id, 0)
      when "NORTH"
        player = player.not_nil!
        teleport_player(player, NORTH_WATCHERS_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(NORTH_WATCHERS_ROOM_LOC, world.instance_id, 0)
      when "SOUTH"
        player = player.not_nil!
        teleport_player(player, SOUTH_WATCHERS_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(SOUTH_WATCHERS_ROOM_LOC, world.instance_id, 0)
      when "CENTER"
        player = player.not_nil!
        teleport_player(player, CENTRAL_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(CENTRAL_ROOM_LOC, world.instance_id, 0)
      when "FOLLOW"
        player = player.not_nil!
        npc.running = true
        npc.ai.start_follow(player)
        if player.in_combat?
          npc.do_cast(BUFFS.sample(random: Rnd))
        end
        start_quest_timer("FOLLOW", 5000, npc, player)
      when "DIALOG"
        player = player.not_nil!
        st_q10294 = player.get_quest_state(Q10294_SevenSignsToTheMonasteryOfSilence.simple_name)
        st_q10295 = player.get_quest_state(Q10295_SevenSignsSolinasTomb.simple_name)
        if st_q10294 && st_q10294.started?
          broadcast_npc_say(npc, Say2::NPC_ALL, ELCADIA_DIALOGS_Q010294.sample)
        end

        if st_q10295 && st_q10295.memo_state?(1)
          broadcast_npc_say(npc, Say2::NPC_ALL, ELCADIA_DIALOGS_Q010295.sample)
        end
        start_quest_timer("DIALOG", 10000, npc, player)
      when "ENTER_Q10295"
        player = player.not_nil!
        teleport_player(player, START_LOC_Q10295, world.instance_id)
        world.elcadia.tele_to_location(START_LOC_Q10295, world.instance_id, 0)
        start_quest_timer("START_MOVIE_Q10295", 2000, npc, player)
      when "START_MOVIE_Q10295"
        player = player.not_nil!
        player.show_quest_movie(26)
      when "CASKET_ROOM"
        player = player.not_nil!
        teleport_player(player, CASKET_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(CASKET_ROOM_LOC, world.instance_id, 0)
      when "SOLINAS_RESTING_PLACE"
        player = player.not_nil!
        teleport_player(player, SOLINAS_RESTING_PLACE_LOC, world.instance_id)
        world.elcadia.tele_to_location(SOLINAS_RESTING_PLACE_LOC, world.instance_id, 0)
      when "ERIS_OFFICE"
        player = player.not_nil!
        teleport_player(player, START_LOC, world.instance_id)
        world.elcadia.tele_to_location(START_LOC, world.instance_id, 0)
      when "OPEN_DOORS"
        DOORS.each do |door_id|
          open_door(door_id, world.instance_id)
        end
      when "DIRECTORS_ROOM"
        player = player.not_nil!
        teleport_player(player, DIRECTORS_ROOM_LOC, world.instance_id)
        world.elcadia.tele_to_location(DIRECTORS_ROOM_LOC, world.instance_id, 0)
      when "USE_SCROLL"
        player = player.not_nil!
        # TODO (Adry_85): Missing area debuff
        if has_quest_items?(player, SCROLL_OF_ABSTINENCE)
          take_items(player, SCROLL_OF_ABSTINENCE, 1)
          add_spawn(SOLINAS_GUARDIAN_1, SOLINAS_GUARDIAN_1_LOC, false, 0, false, world.instance_id)
        end
      when "USE_SHIELD"
        player = player.not_nil!
        # TODO (Adry_85): Missing area debuff
        if has_quest_items?(player, SHIELD_OF_SACRIFICE)
          take_items(player, SHIELD_OF_SACRIFICE, 1)
          add_spawn(SOLINAS_GUARDIAN_2, SOLINAS_GUARDIAN_2_LOC, false, 0, false, world.instance_id)
        end
      when "USE_SWORD"
        player = player.not_nil!
        # TODO (Adry_85): Missing area debuff
        if has_quest_items?(player, SWORD_OF_HOLY_SPIRIT)
          take_items(player, SWORD_OF_HOLY_SPIRIT, 1)
          add_spawn(SOLINAS_GUARDIAN_3, SOLINAS_GUARDIAN_3_LOC, false, 0, false, world.instance_id)
        end
      when "USE_STAFF"
        player = player.not_nil!
        # TODO (Adry_85): Missing area debuff
        if has_quest_items?(player, STAFF_OF_BLESSING)
          take_items(player, STAFF_OF_BLESSING, 1)
          add_spawn(SOLINAS_GUARDIAN_4, SOLINAS_GUARDIAN_4_LOC, false, 0, false, world.instance_id)
        end
      when "CLOSE_TOMB_DOORS"
        FAKE_TOMB_DOORS.each do |door_id|
          close_door(door_id, world.instance_id)
        end
      when "TOMB_GUARDIAN_SPAWN"
        player = player.not_nil!
        FAKE_TOMB_DOORS.each do |door_id|
          open_door(door_id, world.instance_id)
        end

        add_spawn(GUARDIAN_OF_THE_TOMB_1, GUARDIAN_OF_THE_TOMB_1_LOC, false, 0, false, world.instance_id)

        SLAVE_SPAWN_1_LOC.each do |loc|
          mob = add_spawn(TRAINEE_OF_REST, loc, false, 0, false, world.instance_id).as(L2Attackable)
          mob.running = true
          mob.add_damage_hate(player, 0, 999)
          mob.set_intention(AI::ATTACK, player)
        end

        add_spawn(GUARDIAN_OF_THE_TOMB_2, GUARDIAN_OF_THE_TOMB_2_LOC, false, 0, false, world.instance_id)

        SLAVE_SPAWN_2_LOC.each do |loc|
          mob = add_spawn(TRAINEE_OF_REST, loc, false, 0, false, world.instance_id).as(L2Attackable)
          mob.running = true
          mob.add_damage_hate(player, 0, 999)
          mob.set_intention(AI::ATTACK, player)
        end

        add_spawn(GUARDIAN_OF_THE_TOMB_3, GUARDIAN_OF_THE_TOMB_3_LOC, false, 0, false, world.instance_id)

        SLAVE_SPAWN_3_LOC.each do |loc|
          mob = add_spawn(SUPPLICANT_OF_REST, loc, false, 0, false, world.instance_id).as(L2Attackable)
          mob.running = true
          mob.add_damage_hate(player, 0, 999)
          mob.set_intention(AI::ATTACK, player)
        end

        add_spawn(GUARDIAN_OF_THE_TOMB_4, GUARDIAN_OF_THE_TOMB_4_LOC, false, 0, false, world.instance_id)

        SLAVE_SPAWN_4_LOC.each do |loc|
          mob = add_spawn(SUPPLICANT_OF_REST, loc, false, 0, false, world.instance_id).as(L2Attackable)
          mob.running = true
          mob.add_damage_hate(player, 0, 999)
          mob.set_intention(AI::ATTACK, player)
        end
        return "32843-01.html"
      when "START_MOVIE_Q10296"
        player = player.not_nil!
        player.show_quest_movie(29)
        start_quest_timer("TELEPORT_SPACE", 60_000, npc, player)
        world.elcadia.tele_to_location(ELCADIA_LOC, world.instance_id, 0)
      when "TELEPORT_SPACE"
        player = player.not_nil!
        teleport_player(player, SPACE_LOC, world.instance_id)
        world.elcadia.tele_to_location(SPACE_LOC, world.instance_id, 0)
        add_spawn(ETIS_VAN_ETINA, ETIS_VAN_ETINA_LOC, false, 0, false, world.instance_id)
      when "TELEPORT_TO_PLAYER"
        player = player.not_nil!
        world.elcadia.tele_to_location(*player.xyz, 0, world.instance_id)
      end
    end

    super
  end

  def on_kill(npc, pc, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(MOSWorld)
      case npc.id
      when GUARDIAN_OF_THE_TOMB_1, GUARDIAN_OF_THE_TOMB_2,
           GUARDIAN_OF_THE_TOMB_3, GUARDIAN_OF_THE_TOMB_4
        world.dead_tomb_guardian_count &+= 1
        if world.dead_tomb_guardian_count == 4
          open_door(TOMB_DOOR, world.instance_id)
          st = pc.get_quest_state(Q10295_SevenSignsSolinasTomb.simple_name)
          if st && st.memo_state?(2)
            st.memo_state = 3
          end
        end
      when SOLINAS_GUARDIAN_1, SOLINAS_GUARDIAN_2, SOLINAS_GUARDIAN_3,
           SOLINAS_GUARDIAN_4
        world.dead_solina_guardian_count &+= 1
        if world.dead_solina_guardian_count == 4
          pc.show_quest_movie(27)
          st = pc.get_quest_state(Q10295_SevenSignsSolinasTomb.simple_name)
          if st && st.memo_state?(1)
            st.memo_state = 2
          end
        end
      when ETIS_VAN_ETINA
        pc.show_quest_movie(30)
        world.elcadia.tele_to_location(ELCADIA_LOC, world.instance_id, 0)
        start_quest_timer("TELEPORT_TO_PLAYER", 63_000, npc, pc)
        st = pc.get_quest_state(Q10296_SevenSignsOneWhoSeeksThePowerOfTheSeal.simple_name)
        if st && st.memo_state?(2)
          st.memo_state = 3
        end
      end
    end

    nil
  end

  def on_spawn(npc)
    case npc.id
    when ERIS_EVIL_THOUGHTS
      start_quest_timer("OPEN_DOORS", 1000, npc, nil)
    when TOMB_OF_THE_SAINTESS
      start_quest_timer("CLOSE_TOMB_DOORS", 1000, npc, nil)
    end

    super
  end

  def on_talk(npc, talker)
    if npc.id == ODD_GLOBE
      enter_instance(talker, MOSWorld.new, "MonasteryOfSilence.xml", TEMPLATE_ID)
    end

    super
  end

  private def spawn_elcadia(pc, world)
    world.elcadia?.try &.delete_me
    world.elcadia = add_spawn(ELCADIA_INSTANCE, *pc.xyz, 0, false, 0, false, world.instance_id)
    start_quest_timer("FOLLOW", 5000, world.elcadia, pc)
    start_quest_timer("DIALOG", 10_000, world.elcadia, pc)
  end
end
