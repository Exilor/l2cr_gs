class EffectHandler::TriggerSkillByAttack < AbstractEffect
  include Loggable

  @min_attacker_level : Int32
  @max_attacker_level : Int32
  @min_damage : Int32
  @chance : Int32
  @skill : SkillHolder
  @target_type : TargetType
  @attacker_type : InstanceType
  @critical : Bool

  def initialize(attach_cond, apply_cond, set, params)
    super

    @min_attacker_level = params.get_i32("minAttackerLevel", 1)
    @max_attacker_level = params.get_i32("maxAttackerLevel", 100)
    @min_damage = params.get_i32("minDamage", 1)
    @chance = params.get_i32("chance", 100)
    id = params.get_i32("skillId")
    level = params.get_i32("skillLevel", 1)
    @skill = SkillHolder.new(id, level)
    @target_type = params.get_enum("targetType", TargetType, TargetType::SELF)
    @attacker_type = params.get_enum("attackerType", InstanceType, InstanceType::L2Character)
    @critical = params.get_bool("isCritical", false)
    @allow_weapons = 0
    params.get_string("allowWeapons").split(',') do |str|
      break if str.casecmp?("ALL")
      @allow_weapons |= WeaponType.parse(str).mask
    end
  end

  def on_attack_event(event)
    if event.skill || event.damage_over_time? || event.reflect? || @chance == 0 || @skill.skill_id == 0 || @skill.skill_lvl == 0
      return
    end

    return if @critical != event.critical?

    unless handler = TargetHandler[@target_type]
      warn { "No handler for target type #{@target_type}" }
      return
    end

    return if event.attacker == event.target
    return if event.attacker.level < @min_attacker_level
    return if event.attacker.level > @max_attacker_level

    if event.damage < @min_damage || Rnd.rand(100) > @chance || !event.attacker.instance_type?(@attacker_type)
      return
    end

    if @allow_weapons > 0
      return unless weapon = event.attacker.active_weapon_item
      return unless weapon.item_type.mask & @allow_weapons == 0
    end

    unless trigger_skill = @skill.skill?
      return
    end

    targets = handler.get_target_list(trigger_skill, event.attacker, false, event.target)
    targets.each do |t|
      next unless t.is_a?(L2Character)
      unless t.invul?
        event.attacker.make_trigger_cast(trigger_skill, t)
      end
    end
    nil
  end

  def on_exit(info)
    type = EventType::ON_CREATURE_DAMAGE_DEALT
    info.effected.remove_listener_if(type) { |l| l.owner == self }
  end

  def on_start(info)
    char = info.effected
    type = EventType::ON_CREATURE_DAMAGE_DEALT
    listener = ConsumerEventListener.new(char, type, self) do |event|
      on_attack_event(event.as(OnCreatureDamageDealt))
    end
    char.add_listener(listener)
  end
end
