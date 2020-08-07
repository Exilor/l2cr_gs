class Packets::Incoming::RequestPledgeInfo < GameClientPacket
  no_action_request

  @clan_id = 0

  private def read_impl
    @clan_id = d
  end

  private def run_impl
    return unless pc = active_char

    unless clan = ClanTable.get_clan(@clan_id)
      debug { "No clan with id #{@clan_id} was found (requested by #{pc.name})." }
      return
    end

    pc.send_packet(PledgeInfo.new(clan))
  end
end
