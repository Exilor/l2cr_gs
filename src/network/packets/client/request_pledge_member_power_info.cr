class Packets::Incoming::RequestPledgeMemberPowerInfo < GameClientPacket
  @player = ""

  private def read_impl
    d # unknown
    @player = s
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan
    return unless member = clan.get_clan_member(@player)
    pc.send_packet(PledgeReceivePowerInfo.new(member))
  end
end
