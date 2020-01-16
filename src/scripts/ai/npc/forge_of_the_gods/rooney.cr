class Scripts::Rooney < AbstractNpcAI
  # NPC
  private ROONEY = 32049
  # Locations
  private LOCATIONS = {
    Location.new(179221, -115743, -3600),
    Location.new(177668, -118775, -4080),
    Location.new(179906, -108469, -5832),
    Location.new(181285, -113798, -6064),
    Location.new(181805, -108718, -5832),
    Location.new(184131, -117511, -3336),
    Location.new(186418, -112998, -3272)
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_see_creature_id(ROONEY)
    add_spawn(ROONEY, LOCATIONS.sample(random: Rnd), false, 0)
  end

  def on_adv_event(event, npc, player)
    return unless npc

    case event
    when "teleport"
      unless npc.decayed?
        npc.script_value = 0
      end
    when "message1"
      unless npc.decayed?
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HURRY_HURRY)
        start_quest_timer("message2", 60000, npc, nil)
      end
    when "message2"
      unless npc.decayed?
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::I_AM_NOT_THAT_TYPE_OF_PERSON_WHO_STAYS_IN_ONE_PLACE_FOR_A_LONG_TIME)
        start_quest_timer("message3", 60000, npc, nil)
      end
    when "message3"
      unless npc.decayed?
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::ITS_HARD_FOR_ME_TO_KEEP_STANDING_LIKE_THIS)
        start_quest_timer("message4", 60000, npc, nil)
      end
    when "message4"
      unless npc.decayed?
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::WHY_DONT_I_GO_THAT_WAY_THIS_TIME)
      end
    end

    return
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.player? && npc.script_value?(0)
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::WELCOME)
      start_quest_timer("teleport", 3600000, npc, nil)
      start_quest_timer("message1", 60000, npc, nil)
      npc.script_value = 1
    end

    super
  end
end
