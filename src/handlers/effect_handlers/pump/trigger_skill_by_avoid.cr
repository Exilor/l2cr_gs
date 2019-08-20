class EffectHandler::TriggerSkillByAvoid < AbstractEffect
  @chance : Int32
  @target_type : L2TargetType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @chance = params.get_i32("chance", 100)
    id, level = params.get_i32("skillId", 0), params.get_i32("skillLevel", 0)
    @skill = SkillHolder.new(id, level)
    @target_type = params.get_enum("targetType", L2TargetType, L2TargetType::ONE)
  end

  def on_avoid_event(evt)
    evt = evt.as(OnCreatureAttackAvoid)
    return if evt.damage_over_time? || @chance == 0
    return if @skill.skill_id == 0 || @skill.skill_lvl == 0
    return if Rnd.rand(100) > @chance

    unless handler = TargetHandler[@target_type]
      warn { "Handler for #{@target_type.inspect} does not exist." }
      return
    end

    skill = @skill.skill
    targets = handler.get_target_list(skill, evt.target, false, evt.attacker)
    targets.each do |target|
      next unless target.is_a?(L2Character)
      unless target.invul?
        evt.target.make_trigger_cast(skill, target)
      end
    end
  end

  def on_exit(info)
    type = EventType::ON_CREATURE_ATTACK_AVOID
    info.effected.remove_listener_if(type) { |l| l.owner == self }
  end

  def on_start(info)
    char = info.effected
    type = EventType::ON_CREATURE_ATTACK_AVOID
    listener = ConsumerEventListener.new(char, type, self) do |event|
      on_avoid_event(event)
    end
    char.add_listener(listener)
  end
end
