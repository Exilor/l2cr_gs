class Packets::Incoming::RequestPledgeMemberList < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char
    return unless clan = pc.clan?
    pc.send_packet(PledgeShowMemberListAll.new(clan, pc))
  end
end
