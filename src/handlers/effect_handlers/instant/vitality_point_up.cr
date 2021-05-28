class EffectHandler::VitalityPointUp < AbstractEffect
  @value : Float32

  def initialize(attach_cond : Condition?, apply_cond : Condition?, set : StatsSet, params : StatsSet)
    super
    @value = params.get_f32("value", 0)
  end

  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effected.as?(L2PcInstance)

    pc.update_vitality_points(@value, false, false)
    pc.send_packet(UserInfo.new(pc))
  end
end
