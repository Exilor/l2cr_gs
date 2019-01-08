# custom effect

class EffectHandler::TriggerSkillOverTime < AbstractEffect
  @target_type : L2TargetType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @ticks = params.get_i32("ticks", 1)
    id, lvl = params.get_i32("skillId"), params.get_i32("skillLevel", 1)
    @skill = SkillHolder.new(id, lvl)
    @target_type = params.get_enum("targetType", L2TargetType, L2TargetType::SELF)
  end

  def on_start(info)
    debug "on_start"
  end

  def on_action_time(info)
    debug "on_action_time(effector: #{info.effector}, effected: #{info.effected})"
    trigger_skill = @skill.skill
    handler = TargetHandler[@target_type].not_nil!
    handler.get_target_list(trigger_skill, info.effector, false, info.effected)
    .each do |t|
      if t.is_a?(L2Character) && !t.invul?
        debug "#{info.effector} casting #{trigger_skill} on #{t}"
        info.effector.make_trigger_cast(trigger_skill, t)
      end
    end
    true
  end
end
