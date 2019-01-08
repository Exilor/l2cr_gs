class Packets::Incoming::RequestWithdrawalParty < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char
    return unless party = pc.party?

    if party.in_dimensional_rift? && !party.dimensional_rift.revived_at_waiting_room.includes?(pc)
      pc.send_message("You can't exit the party when you are in Dimensional Rift.")
    else
      party.remove_party_member(pc, L2Party::MessageType::Left)
      if pc.in_party_match_room?
        if room = PartyMatchRoomList.get_player_room(pc)
          pc.send_packet(PartyMatchDetail.new(room))
          pc.send_packet(ExPartyRoomMember.new(room, 0))
          pc.send_packet(ExClosePartyRoom::STATIC_PACKET)
        end

        pc.party_room = 0
        pc.broadcast_user_info
      end
    end
  end
end
