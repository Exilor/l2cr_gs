class EffectHandler::CallSkill < AbstractEffect
  def initialize(attach_cond, apply_cond, set, params)
    super

    id = params.get_i32("skillId")
    level = params.get_i32("skillLevel", 1)
    @skill = SkillHolder.new(id, level)
  end

  def instant? : Bool
    true
  end

  def on_start(info)
    info.effector.make_trigger_cast(@skill.skill, info.effected, true)
  end
end
