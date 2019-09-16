struct VitalityTask
  initializer pc: L2PcInstance

  def call
    return unless @pc.inside_peace_zone?
    return if @pc.vitality_points >= PcStat::MAX_VITALITY_POINTS
    rate = Config.rate_recovery_vitality_peace_zone
    @pc.update_vitality_points(rate, false, false)
    info = Packets::Outgoing::ExVitalityPointInfo.new(@pc.vitality_points)
    @pc.send_packet(info)
  end
end
