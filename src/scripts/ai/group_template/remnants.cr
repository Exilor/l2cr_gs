class Scripts::Remnants < AbstractNpcAI
  private NPCS = {
    18463,
    18464,
    18465
  }
  private HOLY_WATER_SKILL = 2358

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_spawn_id(NPCS)
    add_skill_see_id(NPCS)
  end

  def on_spawn(npc)
    npc.mortal = false
    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if skill.id == HOLY_WATER_SKILL
      if npc.alive?
        if targets.first? == npc
          if npc.hp_percent < 2
            npc.do_die(caster)
            # L2J has code commented out here
          end
        end
      end
    end

    super
  end
end
