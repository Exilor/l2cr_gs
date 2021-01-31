class EffectHandler::TriggerSkillByDamage < AbstractEffect
  include Loggable

  @min_attacker_level : Int32
  @max_attacker_level : Int32
  @min_damage : Int32
  @chance : Int32
  @target_type : TargetType
  @attacker_type : InstanceType

  def initialize(attach_cond, apply_cond, set, params)
    super

    @min_attacker_level = params.get_i32("minAttackerLevel", 1)
    @max_attacker_level = params.get_i32("maxAttackerLevel", 100)
    @min_damage = params.get_i32("minDamage", 1)
    @chance = params.get_i32("chance", 100)
    id, lvl = params.get_i32("skillId"), params.get_i32("skillLevel", 1)
    @skill = SkillHolder.new(id, lvl)
    @target_type = params.get_enum("targetType", TargetType, TargetType::SELF)
    @attacker_type = params.get_enum("attackerType", InstanceType, InstanceType::L2Character)
  end

  def on_start(info : BuffInfo)
    char = info.effected
    listener = ConsumerEventListener.new(char, EventType::ON_CREATURE_DAMAGE_RECEIVED, self) do |event|
      on_damage_received(event.as(OnCreatureDamageReceived))
    end
    char.add_listener(listener)
  end

  def on_exit(info : BuffInfo)
    type = EventType::ON_CREATURE_DAMAGE_RECEIVED
    info.effected.remove_listener_if(type) do |listener|
      listener.owner == self
    end
  end

  def on_damage_received(event)
    if @target_type.self? && @skill.skill.cast_range > 0 && Util.calculate_distance(event.attacker, event.target, true, false) > @skill.skill.cast_range
      return
    end
    if event.damage_over_time? || @chance == 0 || @skill.skill_lvl == 0
      return
    end

    return if event.attacker == event.target

    return if event.attacker.level < @min_attacker_level
    return if event.attacker.level > @max_attacker_level
    return if event.damage < @min_damage
    return if Rnd.rand(100) > @chance
    return unless event.attacker.instance_type?(@attacker_type)

    trigger_skill = @skill.skill
    handler = TargetHandler[@target_type].not_nil!
    handler.get_target_list(trigger_skill, event.target, false, event.attacker)
    .each do |t|
      if t.is_a?(L2Character) && !t.invul?
        event.target.make_trigger_cast(trigger_skill, t)
      end
    end
  end
end
