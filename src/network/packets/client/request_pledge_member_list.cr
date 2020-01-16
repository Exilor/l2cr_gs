class Packets::Incoming::RequestPledgeMemberList < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan
    pc.send_packet(PledgeShowMemberListAll.new(clan, pc))
  end
end
