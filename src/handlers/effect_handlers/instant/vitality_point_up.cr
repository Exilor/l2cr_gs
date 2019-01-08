class EffectHandler::VitalityPointUp < AbstractEffect
  @value : Float32

  def initialize(attach_cond, apply_cond, set, params)
    super
    @value = params.get_f32("value", 0)
  end

  def instant?
    true
  end

  def on_start(info)
    return unless pc = info.effected?.as?(L2PcInstance)

    pc.update_vitality_points(@value, false, false)
    pc.send_packet(UserInfo.new(pc))
  end
end
