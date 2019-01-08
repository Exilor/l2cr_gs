class Packets::Incoming::RequestPartyMatchConfig < GameClientPacket
  @auto = 0
  @loc = 0
  @lvl = 0

  def read_impl
    @auto = d
    @loc = d
    @lvl = d
  end

  def run_impl
    return unless pc = active_char

    if !pc.in_party_match_room? && pc.party? && pc.party.leader != pc
      pc.send_packet(SystemMessageId::CANT_VIEW_PARTY_ROOMS)
      action_failed
      return
    end

    if pc.in_party_match_room?
      return unless room = PartyMatchRoomList.get_player_room(pc)
      pc.send_packet(PartyMatchDetail.new(room))
      pc.send_packet(ExPartyRoomMember.new(room, 2))
      pc.party_room = room.id
      pc.broadcast_user_info
    else
      PartyMatchWaitingList.add_player(pc)
      pc.send_packet(ListPartyWating.new(pc, @auto, @loc, @lvl))
    end
  end
end
