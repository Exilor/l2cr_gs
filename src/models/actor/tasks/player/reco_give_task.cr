struct RecoGiveTask
  include Runnable

  initializer pc: L2PcInstance

  def run
    reco_to_give = 1
    unless @pc.reco_two_hours_given?
      reco_to_give = 10
      @pc.reco_two_hours_given = true
    end
    @pc.recom_left += reco_to_give
    sm = Packets::Outgoing::SystemMessage.you_obtained_s1_recommendations
    sm.add_int(reco_to_give)
    @pc.send_packet(sm)
    @pc.send_packet(Packets::Outgoing::UserInfo.new(@pc))
  end
end
