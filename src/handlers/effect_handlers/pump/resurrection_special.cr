class EffectHandler::ResurrectionSpecial < AbstractEffect
  @res_power : Int32
  @res_recovery : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super

    @res_power = params.get_i32("resPower", 0)
    @res_recovery = params.get_i32("resRecovery", 0)
  end

  def effect_type : EffectType
    EffectType::RESURRECTION_SPECIAL
  end

  def effect_flags
    EffectFlag::RESURRECTION_SPECIAL.mask
  end

  def on_exit(info : BuffInfo)
    effected, effector, skill = info.effected, info.effector, info.skill
    return unless caster = effector.acting_player

    case effected
    when L2PcInstance
      effected.revive_request(caster, skill, false, @res_power, @res_recovery)
    when L2PetInstance
      effected.owner.revive_request(effected.owner, skill, true, @res_power, @res_recovery)
    end
  end
end
