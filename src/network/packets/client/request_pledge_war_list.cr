class Packets::Incoming::RequestPledgeWarList < GameClientPacket
  @unk = 0
  @tab = 0

  private def read_impl
    @unk = d
    @tab = d
  end

  private def run_impl
    return unless (pc = active_char) && (clan = pc.clan)
    pc.send_packet(PledgeReceiveWarList.new(clan, @tab))
  end
end
