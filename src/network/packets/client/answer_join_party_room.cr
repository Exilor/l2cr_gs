class Packets::Incoming::AnswerJoinPartyRoom < GameClientPacket
  @answer = 0

  private def read_impl
    @answer = d
  end

  private def run_impl
    return unless pc = active_char

    partner = pc.active_requester

    if partner.nil? || L2World.get_player(partner.l2id).nil?
      pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
      pc.active_requester = nil
      return
    end

    if @answer == 1 && !partner.request_expired?
      unless room = PartyMatchRoomList.get_room(partner.party_room)
        warn { "No party match room found with id #{partner.party_room}." }
        return
      end

      if pc.level.between?(room.min_lvl, room.max_lvl)
        PartyMatchWaitingList.remove_player(pc)
        pc.party_room = partner.party_room
        pc.send_packet(PartyMatchDetail.new(room))
        pc.send_packet(ExPartyRoomMember.new(room, 0))

        room.party_members.each do |m|
          m.send_packet(ExManagePartyRoomMember.new(pc, room, 0))
          sm = SystemMessage.c1_entered_party_room
          sm.add_pc_name(pc)
          m.send_packet(sm)
        end

        room.add_member(pc)

        pc.broadcast_user_info
      else
        pc.send_packet(SystemMessageId::CANT_ENTER_PARTY_ROOM)
      end
    else
      partner.send_packet(SystemMessageId::PARTY_MATCHING_REQUEST_NO_RESPONSE)
    end

    pc.active_requester = nil
    partner.on_transaction_response
  end
end
