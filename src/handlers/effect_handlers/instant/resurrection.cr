class EffectHandler::Resurrection < AbstractEffect
  @power : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_i32("power", 0)
  end

  def effect_type
    L2EffectType::RESURRECTION
  end

  def instant?
    true
  end

  def on_start(info)
    target, caster = info.effected, info.effector

    if caster.player?
      if target.acting_player?
        target.acting_player.revive_request(caster.acting_player, info.skill, target.pet?, @power, 0)
      end
    else
      DecayTaskManager.cancel(target)
      target.do_revive(Formulas.skill_resurrect_restore_percent(@power.to_f, caster))
    end
  end
end
