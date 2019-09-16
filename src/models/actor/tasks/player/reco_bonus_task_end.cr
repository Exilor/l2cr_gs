struct RecoBonusTaskEnd
  initializer pc: L2PcInstance

  def call
    @pc.send_packet(Packets::Outgoing::ExVoteSystemInfo.new(@pc))
  end
end
