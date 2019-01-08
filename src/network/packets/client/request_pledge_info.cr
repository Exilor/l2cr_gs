class Packets::Incoming::RequestPledgeInfo < GameClientPacket
  no_action_request

  @clan_id = 0

  def read_impl
    @clan_id = d
  end

  def run_impl
    return unless pc = active_char

    if Config.debug
      debug "#{pc.name} requests info for clan #{@clan_id}."
    end

    unless clan = ClanTable.get_clan(@clan_id)
      if Config.debug
        warn "No clan with ID #{@clan_id} was found (requested by #{pc.name})."
      end

      return
    end

    pc.send_packet(PledgeInfo.new(clan))
  end
end
