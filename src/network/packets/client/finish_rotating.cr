class Packets::Incoming::FinishRotating < GameClientPacket
  @degree = 0

  private def read_impl
    @degree = d
    # @unknown = d
  end

  private def run_impl
    return unless pc = active_char
    airship = pc.airship
    if airship && airship.captain?(pc)
      airship.heading = @degree
      sr = StopRotation.new(airship.l2id, @degree, 0)
      airship.broadcast_packet(sr)
    else
      pc.broadcast_packet(StopRotation.new(pc.l2id, @degree, 0))
    end
  end
end
