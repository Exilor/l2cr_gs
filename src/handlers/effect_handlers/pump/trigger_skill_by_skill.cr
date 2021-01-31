class EffectHandler::TriggerSkillBySkill < AbstractEffect
  include Loggable

  @cast_skill_id : Int32
  @chance : Int32
  @target_type : TargetType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @cast_skill_id = params.get_i32("castSkillId", 0)
    @chance = params.get_i32("chance", 100)
    id, level = params.get_i32("skillId", 0), params.get_i32("skillLevel", 0)
    @skill = SkillHolder.new(id, level)
    @target_type = params.get_enum("targetType", TargetType, TargetType::ONE)
  end

  def on_skill_use_event(evt)
    return if @chance == 0 || @skill.skill_id == 0 || @skill.skill_lvl == 0
    return if @cast_skill_id != evt.skill.id
    return if Rnd.rand(100) > @chance

    unless handler = TargetHandler[@target_type]
      warn { "Handler for #{@target_type} does not exist." }
      return
    end

    skill = @skill.skill
    targets = handler.get_target_list(skill, evt.caster, false, evt.target)

    targets.each do |target|
      next unless target.is_a?(L2Character)
      unless target.invul?
        evt.caster.make_trigger_cast(skill, target)
      end
    end
  end

  def on_exit(info : BuffInfo)
    type = EventType::ON_CREATURE_SKILL_USE
    info.effected.remove_listener_if(type) { |l| l.owner == self }
  end

  def on_start(info : BuffInfo)
    char = info.effected
    type = EventType::ON_CREATURE_SKILL_USE
    listener = ConsumerEventListener.new(char, type, self) do |event|
      on_skill_use_event(event.as(OnCreatureSkillUse))
    end
    char.add_listener(listener)
  end
end
