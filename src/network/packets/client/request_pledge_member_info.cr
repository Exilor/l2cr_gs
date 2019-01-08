class Packets::Incoming::RequestPledgeMemberInfo < GameClientPacket
  @player = ""

  def read_impl
    unk = d
    @player = s
  end

  def run_impl
    return unless pc = active_char
    return unless clan = pc.clan?
    unless member = clan.get_clan_member(@player)
      warn "Requested info about clan member with name #{@player.inspect} but was not found."
      return
    end
    pc.send_packet(PledgeReceiveMemberInfo.new(member))
  end
end
