class EffectHandler::CallSkill < AbstractEffect
  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super

    id = params.get_i32("skillId")
    level = params.get_i32("skillLevel", 1)
    @skill = SkillHolder.new(id, level)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    info.effector.make_trigger_cast(@skill.skill, info.effected, true)
  end
end
