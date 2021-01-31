class EffectHandler::StealAbnormal < AbstractEffect
  @slot : DispelCategory
  @rate : Int32
  @max : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @slot = params.get_enum("slot", DispelCategory, DispelCategory::BUFF)
    @rate = params.get_i32("rate", 0)
    @max  = params.get_i32("max", 0)
  end

  def effect_type : EffectType
    EffectType::STEAL_ABNORMAL
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effector, effected = info.effector, info.effected

    return unless effected.player?

    return if effected == effector

    buffs = Formulas.steal_effects(effector, effected, info.skill, @slot, @rate, @max)
    buffs.each do |buff|
      stolen = BuffInfo.new(effected, effector, buff.skill)
      stolen.abnormal_time = buff.time
      buff.skill.apply_effect_scope(EffectScope::GENERAL, stolen, true, true)
      effected.effect_list.remove(true, buff)
      effector.effect_list.add(stolen)
    end
  end
end
