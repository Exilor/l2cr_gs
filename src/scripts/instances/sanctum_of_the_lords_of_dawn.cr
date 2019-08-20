class Scripts::SanctumOftheLordsOfDawn < AbstractInstance
  private class SotLoDWorld < InstanceWorld
    MONSTERS = {} of Int32 => Array(L2Npc)
    property doors : Int32 = 0
  end

  # NPCs
  private GUARDS_OF_THE_DAWN = 18834
  private GUARDS_OF_THE_DAWN_2 = 18835
  private GUARDS_OF_THE_DAWN_3 = 27351
  private LIGHT_OF_DAWN = 32575
  private PASSWORD_ENTRY_DEVICE = 32577
  private IDENTITY_CONFIRM_DEVICE = 32578
  private DARKNESS_OF_DAWN = 32579
  private SHELF = 32580
  # Item
  private IDENTITY_CARD = 13822
  # Skill
  private GUARD_SKILL = SkillHolder.new(5978)
  # Locations
  private ENTER = Location.new(-76161, 213401, -7120, 0, 0)
  private EXIT = Location.new(-12585, 122305, -2989, 0, 0)
  # Misc
  private TEMPLATE_ID = 111
  private DOOR_ONE = 17240001
  private DOOR_TWO = 17240003
  private DOOR_THREE = 17240005
  private SAVE_POINT = {
    Location.new(-75775, 213415, -7120),
    Location.new(-74959, 209240, -7472),
    Location.new(-77699, 208905, -7640),
    Location.new(-79939, 205857, -7888)
  }

  def initialize
    super(self.class.simple_name)

    add_start_npc(LIGHT_OF_DAWN)
    add_talk_id(
      LIGHT_OF_DAWN, IDENTITY_CONFIRM_DEVICE, PASSWORD_ENTRY_DEVICE,
      DARKNESS_OF_DAWN, SHELF
    )
    add_aggro_range_enter_id(
      GUARDS_OF_THE_DAWN, GUARDS_OF_THE_DAWN_2, GUARDS_OF_THE_DAWN_3
    )
  end

  def on_adv_event(event, npc, pc)
    case event
    when "spawn"
      pc = pc.not_nil!
      world = InstanceManager.get_player_world(pc)
      if world.is_a?(SotLoDWorld)
        spawn_group("high_priest_of_dawn", world.instance_id)
        pc.send_packet(SystemMessageId::BY_USING_THE_SKILL_OF_EINHASAD_S_HOLY_SWORD_DEFEAT_THE_EVIL_LILIMS)
      end
    when "teleportPlayer"
      pc = pc.not_nil!
      npc = npc.not_nil!
      case npc.id
      when GUARDS_OF_THE_DAWN
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::INTRUDER_PROTECT_THE_PRIESTS_OF_DAWN)
      when GUARDS_OF_THE_DAWN_2
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HOW_DARE_YOU_INTRUDE_WITH_THAT_TRANSFORMATION_GET_LOST)
      when GUARDS_OF_THE_DAWN_3
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::WHO_ARE_YOU_A_NEW_FACE_LIKE_YOU_CAN_T_APPROACH_THIS_PLACE)
      end

      SotLoDWorld::MONSTERS.each do |id, monsters|
        if tmp = monsters.find { |monster| monster.l2id == npc.l2id }
          pc.tele_to_location(SAVE_POINT[id])
          break
        end
      end
    end

    super
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world.add_allowed(pc.l2id)
      save_point = SotLoDWorld::MONSTERS
      save_point[0] = spawn_group("save_point1", world.instance_id)
      save_point[1] = spawn_group("save_point2", world.instance_id)
      save_point[2] = spawn_group("save_point3", world.instance_id)
      save_point[3] = spawn_group("save_point4", world.instance_id)
    end

    teleport_player(pc, ENTER, world.instance_id)
  end

  def on_talk(npc, pc)
    case npc.id
    when LIGHT_OF_DAWN
      qs = pc.get_quest_state(Q00195_SevenSignsSecretRitualOfThePriests.simple_name)
      if qs && qs.cond?(3) && has_quest_items?(pc, IDENTITY_CARD)
        if pc.transformation_id == 113
          enter_instance(pc, SotLoDWorld.new, "SanctumoftheLordsofDawn.xml", TEMPLATE_ID)
          return "32575-01.html"
        end
      end
      return "32575-02.html"
    when IDENTITY_CONFIRM_DEVICE
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(SotLoDWorld)
        if has_quest_items?(pc, IDENTITY_CARD) && pc.transformation_id == 113
          if world.doors == 0
            open_door(DOOR_ONE, world.instance_id)
            pc.send_packet(SystemMessageId::SNEAK_INTO_DAWNS_DOCUMENT_STORAGE)
            pc.send_packet(SystemMessageId::MALE_GUARDS_CAN_DETECT_FEMALES_DONT)
            pc.send_packet(SystemMessageId::FEMALE_GUARDS_NOTICE_BETTER_THAN_MALE)
            world.doors += 1
            npc.decay_me
          elsif world.doors == 1
            open_door(DOOR_TWO, world.instance_id)
            world.doors += 1
            npc.decay_me
            world.allowed.each do |l2id|
              if pl = L2World.get_player(l2id)
                pl.show_quest_movie(11)
                start_quest_timer("spawn", 35000, nil, pc)
              end
            end
          end

          return "32578-01.html"
        end

        return "32578-02.html"
      end
    when PASSWORD_ENTRY_DEVICE
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(SotLoDWorld)
        open_door(DOOR_THREE, world.instance_id)
        return "32577-01.html"
      end
    when DARKNESS_OF_DAWN
      world = InstanceManager.get_player_world(pc).not_nil!
      world.remove_allowed(pc.l2id)
      pc.tele_to_location(EXIT, 0)
      return "32579-01.html"
    when SHELF
      world = InstanceManager.get_world(npc.instance_id).not_nil!
      InstanceManager.get_instance!(world.instance_id).duration = 300000
      pc.tele_to_location(-75925, 213399, -7128)
      return "32580-01.html"
    end

    ""
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    msu = MagicSkillUse.new(npc, pc, GUARD_SKILL.skill_id, 1, 2000, 1)
    npc.broadcast_packet(msu)
    start_quest_timer("teleportPlayer", 2000, npc, pc)

    super
  end
end
