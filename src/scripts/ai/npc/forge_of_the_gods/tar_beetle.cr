class NpcAI::TarBeetle < AbstractNpcAI
  # NPC
  private TAR_BEETLE = 18804
  # Skills
  private TAR_SPITE = 6142
  private SKILLS = {
    SkillHolder.new(TAR_SPITE, 1),
    SkillHolder.new(TAR_SPITE, 2),
    SkillHolder.new(TAR_SPITE, 3)
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    @SPAWN = TarBeetleSpawn.new

    add_aggro_range_enter_id(TAR_BEETLE)
    add_spell_finished_id(TAR_BEETLE)
  end

  def on_aggro_range_enter(npc, player, is_summon)
    if npc.script_value > 0
      info = player.effect_list.get_buff_info_by_skill_id(TAR_SPITE)
      level = info ? info.skill.abnormal_lvl : 0
      if level < 3
        skill = SKILLS[level].skill
        unless npc.skill_disabled?(skill)
          npc.target = player
          npc.do_cast(skill)
        end
      end
    end

    super
  end

  def on_spell_finished(npc, player, skill)
    if skill && skill.id == TAR_SPITE
      val = npc.script_value - 1
      if val <= 0 || SKILLS[0].skill.mp_consume2 > npc.current_mp
        @SPAWN.remove_beetle(npc)
      else
        npc.script_value = val
      end
    end

    super
  end
end
