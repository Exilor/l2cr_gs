class Packets::Incoming::RequestReplySurrenderPledgeWar < GameClientPacket
  @req_name = ""
  @answer = 0

  private def read_impl
    @req_name = s
    @answer = d
  end

  private def run_impl
    return unless pc = active_char
    return unless requestor = pc.active_requester

    if @answer == 1
      ClanTable.delete_clan_war(requestor.clan_id, pc.clan_id)
    else
      warn { "Answer #{@answer} with name #{@req_name} not currently handled." }
    end

    pc.on_transaction_response
  end
end
