class Packets::Incoming::StartRotating < GameClientPacket
  @degree = 0
  @side = 0

  private def read_impl
    @degree = d
    @side = d
  end

  private def run_impl
    return unless pc = active_char

    # if pc.in_airship? && pc.airship.captain?(pc)
    #   sr = StartRotation.new(pc.airship.l2id, @degree, @side, 0)
    #   pc.airship.broadcast_packet(sr)
    # else
      pc.broadcast_packet(StartRotation.new(pc.l2id, @degree, @side, 0))
    # end
  end
end
