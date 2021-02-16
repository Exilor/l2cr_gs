class Scripts::PlainsOfDion < AbstractNpcAI
  private DELU_LIZARDMEN = {
    21104, # Delu Lizardman Supplier
    21105, # Delu Lizardman Special Agent
    21107  # Delu Lizardman Commander
  }

  private MONSTERS_MSG = {
    NpcString::S1_HOW_DARE_YOU_INTERRUPT_OUR_FIGHT_HEY_GUYS_HELP,
    NpcString::S1_HEY_WERE_HAVING_A_DUEL_HERE,
    NpcString::THE_DUEL_IS_OVER_ATTACK,
    NpcString::FOUL_KILL_THE_COWARD,
    NpcString::HOW_DARE_YOU_INTERRUPT_A_SACRED_DUEL_YOU_MUST_BE_TAUGHT_A_LESSON
  }

  private MONSTERS_ASSIST_MSG = {
    NpcString::DIE_YOU_COWARD,
    NpcString::KILL_THE_COWARD,
    NpcString::WHAT_ARE_YOU_LOOKING_AT
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")
    add_attack_id(DELU_LIZARDMEN)
  end

  def on_attack(npc, pc, damage, is_summon)
    if npc.script_value?(0)
      i = Rnd.rand(5)

      if i < 2
        broadcast_npc_say(npc, Say2::NPC_ALL, MONSTERS_MSG[i], pc.name)
      else
        broadcast_npc_say(npc, Say2::NPC_ALL, MONSTERS_MSG[i])
      end

      npc.known_list.get_known_characters_in_radius(npc.template.clan_help_range) do |obj|
        if obj.is_a?(L2MonsterInstance) && DELU_LIZARDMEN.includes?(obj.id)
          if !obj.attacking_now? && obj.alive?
            if GeoData.can_see_target?(npc, obj)
              add_attack_desire(obj, pc)
              msg = MONSTERS_ASSIST_MSG.sample
              broadcast_npc_say(obj, Say2::NPC_ALL, msg)
            end
          end
        end
      end

      npc.script_value = 1
    end

    super
  end
end
