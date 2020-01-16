class Packets::Incoming::RequestOustFromPartyRoom < GameClientPacket
  @char_id = 0

  private def read_impl
    @char_id = d
  end

  private def run_impl
    return unless pc = active_char
    return unless member = L2World.get_player(@char_id)
    return unless room = PartyMatchRoomList.get_player_room(member)
    return unless room.owner == pc

    if pc.party && member.party && pc.party == member.party
      pc.send_packet(SystemMessageId::CANNOT_DISMISS_PARTY_MEMBER)
      return
    end

    room.delete_member(member)
    member.party_room = 0

    member.send_packet(ExClosePartyRoom::STATIC_PACKET)

    PartyMatchWaitingList.add_player(member)

    loc = 0 # L2J TODO: closest town
    member.send_packet(ListPartyWating.new(member, 0, loc, member.level))

    member.broadcast_user_info
    member.send_packet(SystemMessageId::OUSTED_FROM_PARTY_ROOM)
  end
end
