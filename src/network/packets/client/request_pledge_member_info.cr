class Packets::Incoming::RequestPledgeMemberInfo < GameClientPacket
  @player_name = ""

  private def read_impl
    unk = d
    @player_name = s
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan
    unless member = clan.get_clan_member(@player_name)
      warn { "Requested info about clan member with name '#{@player_name}' but was not found." }
      return
    end
    pc.send_packet(PledgeReceiveMemberInfo.new(member))
  end
end
