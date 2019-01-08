struct RecoBonusTaskEnd
  include Runnable

  initializer pc: L2PcInstance

  def run
    @pc.send_packet(Packets::Outgoing::ExVoteSystemInfo.new(@pc))
  end
end
