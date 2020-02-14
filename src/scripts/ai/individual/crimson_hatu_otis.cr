class Scripts::CrimsonHatuOtis < AbstractNpcAI
  # Npc
  private CRIMSON_HATU_OTIS = 18558
  # Skills
  private BOSS_SPINING_SLASH = SkillHolder.new(4737)
  private BOSS_HASTE = SkillHolder.new(4175)

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(CRIMSON_HATU_OTIS)
    add_kill_id(CRIMSON_HATU_OTIS)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    case event
    when "SKILL"
      if npc.dead?
        cancel_quest_timer("SKILL", npc, nil)
        return
      end
      npc.target = pc
      npc.do_cast(BOSS_SPINING_SLASH)
      start_quest_timer("SKILL", 60000, npc, nil)
    when "BUFF"
      if npc.script_value?(2)
        npc.target = npc
        npc.do_cast(BOSS_HASTE)
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.script_value?(0)
      npc.script_value = 1
      start_quest_timer("SKILL", 5000, npc, nil)
    elsif npc.script_value?(1) && npc.hp_percent < 30
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::IVE_HAD_IT_UP_TO_HERE_WITH_YOU_ILL_TAKE_CARE_OF_YOU)
      npc.script_value = 2
      start_quest_timer("BUFF", 1000, npc, nil)
    end

    super
  end

  def on_kill(npc, pc, is_summon)
    cancel_quest_timer("SKILL", npc, nil)
    cancel_quest_timer("BUFF", npc, nil)

    super
  end
end
