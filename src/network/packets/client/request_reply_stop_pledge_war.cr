class Packets::Incoming::RequestReplyStopPledgeWar < GameClientPacket
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
      requestor.send_packet(SystemMessageId::REQUEST_TO_END_WAR_HAS_BEEN_DENIED)
    end

    pc.active_requester = nil
    pc.on_transaction_response
  end
end
