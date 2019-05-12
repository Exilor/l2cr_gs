class Scripts::NecromancerOfTheValley < AbstractNpcAI
  # NPCs
  private EXPLODING_ORC_GHOST = 22818
  private WRATHFUL_ORC_GHOST = 22819
  private NECROMANCER_OF_THE_VALLEY = 22858
  # Skill
  private SELF_DESTRUCTION = SkillHolder.new(6850)
  # Misc
  private HP_PERCENTAGE = 0.60

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(NECROMANCER_OF_THE_VALLEY)
    add_spell_finished_id(EXPLODING_ORC_GHOST)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.current_hp < npc.max_hp * HP_PERCENTAGE
      if Rnd.rand(10) < 1
        if Rnd.bool
          ghost = add_spawn(EXPLODING_ORC_GHOST, *npc.xyz, 0, false, 0, false)
          add_attack_desire(ghost, attacker, 10000)
          add_skill_cast_desire(npc, attacker, SELF_DESTRUCTION, 999999999)
        else
          ghost = add_spawn(WRATHFUL_ORC_GHOST, *npc.xyz, 0, false, 0, false)
          add_attack_desire(ghost, attacker, 10000)
        end
      end
    end

    super
  end

  def on_spell_finished(npc, player, skill)
    if npc && npc.alive? && skill == SELF_DESTRUCTION.skill
      npc.do_die(player)
    end

    super
  end
end
