class EffectHandler::GiveSp < AbstractEffect
  @sp : Int32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @sp = params.get_i32("sp", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    effected, effector = info.effected, info.effector
    if effector.is_a?(L2PcInstance) && effected.is_a?(L2PcInstance)
      effector.add_exp_and_sp(0, @sp)
    end
  end
end
