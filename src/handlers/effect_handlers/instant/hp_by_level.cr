class EffectHandler::HpByLevel < AbstractEffect
  @power : Float64

  def initialize(attach_cond, apply_cond, set, params)
    super
    @power = params.get_f64("power", 0)
  end

  def effect_type
    L2EffectType::BUFF
  end

  def instant?
    true
  end

  def on_start(info)
    abs = @power
    target = info.effector
    if target.current_hp > target.max_hp
      absorb = target.max_hp.to_f64
    else
      absorb = target.current_hp + abs
    end
    restored = absorb - target.current_hp
    target.current_hp = absorb
    sm = SystemMessage.s1_hp_has_been_restored
    sm.add_int(restored)
    target.send_packet(sm)
  end
end
