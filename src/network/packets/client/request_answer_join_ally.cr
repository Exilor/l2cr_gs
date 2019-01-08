class Packets::Incoming::RequestAnswerJoinAlly < GameClientPacket
  @response = 0

  def read_impl
    @response = d
  end

  def run_impl
    return unless pc = active_char
    unless requestor = pc.request.partner
      warn "No request partner."
      return
    end

    if @response == 0
      pc.send_packet(SystemMessageId::YOU_DID_NOT_RESPOND_TO_ALLY_INVITATION)
      requestor.send_packet(SystemMessageId::NO_RESPONSE_TO_ALLY_INVITATION)
    else
      unless requestor.request.request_packet.is_a?(RequestJoinAlly)
        return
      end

      clan = requestor.clan

      if clan.check_ally_join_condition(requestor, pc)
        requestor.send_packet(SystemMessageId::YOU_HAVE_SUCCEEDED_INVITING_FRIEND)
        pc.send_packet(SystemMessageId::YOU_ACCEPTED_ALLIANCE)

        pc.clan.ally_id = clan.ally_id
        pc.clan.ally_name = clan.ally_name
        pc.clan.set_ally_penalty_expiry_time(0, 0)
        pc.clan.change_ally_crest(clan.ally_crest_id, true)
        pc.clan.update_clan_in_db
      end
    end

    pc.request.on_request_response
  end
end
