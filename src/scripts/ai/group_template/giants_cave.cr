class Scripts::GiantsCave < AbstractNpcAI
  # NPC
  private SCOUTS = {
    22668, # Gamlin (Scout)
    22669  # Leogul (Scout)
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_attack_id(SCOUTS)
    add_aggro_range_enter_id(SCOUTS)
  end

  def on_adv_event(event, npc, player)
    if event == "ATTACK" && player && npc && npc.alive?
      if npc.id == SCOUTS[0] # Gamli
        broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::INTRUDER_DETECTED)
      else
        broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::OH_GIANTS_AN_INTRUDER_HAS_BEEN_DISCOVERED)
      end

      npc.known_list.each_character(450) do |char|
        if char.is_a?(L2Attackable) && Rnd.bool
          add_attack_desire(char, player)
        end
      end
    elsif event == "CLEAR" && npc && npc.alive?
      npc.script_value = 0
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.script_value?(0)
      npc.script_value = 1
      start_quest_timer("ATTACK", 6000, npc, attacker)
      start_quest_timer("CLEAR", 120000, npc, nil)
    end

    super
  end

  def on_aggro_range_enter(npc, player, is_summon)
    if npc.script_value?(0)
      npc.script_value = 1
      if Rnd.bool
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::YOU_GUYS_ARE_DETECTED)
      else
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::WHAT_KIND_OF_CREATURES_ARE_YOU)
      end
      start_quest_timer("ATTACK", 6000, npc, player)
      start_quest_timer("CLEAR", 120000, npc, nil)
    end

    super
  end
end
