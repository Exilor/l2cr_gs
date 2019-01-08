class EffectHandler::FocusEnergy < AbstractEffect
  @charge : Int32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @charge = params.get_i32("charge", 0)
  end

  def on_start(info)
    if info.effected.player?
      info.effected.acting_player.increase_charges(1, @charge)
    end
  end

  def instant?
    true
  end
end
