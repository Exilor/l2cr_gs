require "../../../enums/dispel_category"

class EffectHandler::DispelByCategory < AbstractEffect
  @slot : DispelCategory
  @rate : Int32
  @max : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @slot = params.get_enum("slot", DispelCategory, DispelCategory::BUFF)
    @rate = params.get_i32("rate", 0)
    @max = params.get_i32("max", 0)
  end

  def effect_type : EffectType
    EffectType::DISPEL
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effected = info.effected
    return if effected.dead?
    effector = info.effector
    skill = info.skill
    cancelled = Formulas.steal_effects(effector, effected, skill, @slot, @rate, @max)
    cancelled.each do |ccl|
      effected.stop_skill_effects(true, ccl.skill)
    end
  end
end
