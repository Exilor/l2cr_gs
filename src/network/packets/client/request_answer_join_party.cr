require "../../../models/party_match_room_list"

class Packets::Incoming::RequestAnswerJoinParty < GameClientPacket
  @response = 0

  private def read_impl
    @response = d
  end

  private def run_impl
    return unless pc = active_char

    unless requestor = pc.active_requester
      warn { "#{pc} has no active requester." }
      return
    end

    requestor.send_packet(JoinParty.new(@response))

    case @response
    when -1 # party disabled by client config
      sm = SystemMessage.c1_is_set_to_refuse_party_request
      sm.add_pc_name(pc)
      requestor.send_packet(sm)
    when 0 # party cancel
      # nothing
    when 1 # party accept
      if party = requestor.party
        if party.size >= 9
          sm = SystemMessageId::PARTY_FULL
          pc.send_packet(sm)
          requestor.send_packet(sm)
          return
        end
        pc.join_party(party)
      else
        party = L2Party.new(requestor, requestor.party_distribution_type)
        requestor.party = party
        pc.join_party(party)
      end
      if requestor.in_party_match_room? && pc.in_party_match_room?
        room = PartyMatchRoomList.get_player_room(requestor)
        if room && room == PartyMatchRoomList.get_player_room(pc)
          packet = ExManagePartyRoomMember.new(pc, room, 1)
          room.party_members.each &.send_packet(packet)
        end
      elsif requestor.in_party_match_room? && pc.in_party_match_room?
        if room = PartyMatchRoomList.get_player_room(requestor)
          room.add_member(pc)
          packet = ExManagePartyRoomMember.new(pc, room, 1)
          room.party_members.each &.send_packet(packet)
          pc.party_room = room.id
          pc.broadcast_user_info
        end
      end
    else
      # [automatically added else]
    end


    requestor.party.try &.pending_invitation = false

    pc.active_requester = nil
    requestor.on_transaction_response
  end
end
