class Scripts::NecromancerOfTheValley < AbstractNpcAI
  # NPCs
  private EXPLODING_ORC_GHOST = 22818
  private WRATHFUL_ORC_GHOST = 22819
  private NECROMANCER_OF_THE_VALLEY = 22858
  # Skill
  private SELF_DESTRUCTION = SkillHolder.new(6850)
  # Variable
  private MID_HP_FLAG = "MID_HP_FLAG"
  # Misc
  private HP_PERCENTAGE = 60

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(NECROMANCER_OF_THE_VALLEY)
    add_spawn_id(EXPLODING_ORC_GHOST)
    add_spell_finished_id(EXPLODING_ORC_GHOST)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.hp_percent < HP_PERCENTAGE
      if Rnd.rand(100) < 10 && !npc.variables.get_bool(MID_HP_FLAG, false)
        npc.variables[MID_HP_FLAG] = true
        if Rnd.bool
          ghost = add_spawn(EXPLODING_ORC_GHOST, npc, true)
        else
          ghost = add_spawn(WRATHFUL_ORC_GHOST, npc, true)
        end
        add_attack_desire(ghost, attacker, 10000)
      end
    end

    super
  end

  def on_spawn(npc)
    npc.known_list.get_known_characters_in_radius(200) do |obj|
      if obj.player? && obj.alive?
        add_skill_cast_desire(npc, obj, SELF_DESTRUCTION, 1000000)
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
