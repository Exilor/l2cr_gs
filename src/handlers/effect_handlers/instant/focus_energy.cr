class EffectHandler::FocusEnergy < AbstractEffect
  @charge : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @charge = params.get_i32("charge", 0)
  end

  def on_start(info : BuffInfo)
    if pc = info.effected.as?(L2PcInstance)
      pc.increase_charges(1, @charge)
    end
  end

  def instant? : Bool
    true
  end
end
