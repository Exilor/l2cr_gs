class EffectHandler::HpByLevel < AbstractEffect
  @power : Float64

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @power = params.get_f64("power", 0)
  end

  def effect_type : EffectType
    EffectType::BUFF
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
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
