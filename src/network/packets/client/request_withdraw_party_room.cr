class Packets::Incoming::RequestWithdrawPartyRoom < GameClientPacket
  @room_id = 0

  private def read_impl
    @room_id = d
    unk1 = d
  end

  private def run_impl
    return unless pc = active_char

    unless room = PartyMatchRoomList.get_room(@room_id)
      debug "Room #{@room_id} not found."
      return
    end

    if pc.in_party? && room.owner.in_party?
      if pc.party.leader_l2id == room.owner.party.leader_l2id
        pc.broadcast_user_info

        return
      end
    end

    room.delete_member(pc)
    pc.party_room = 0
    pc.send_packet(ExClosePartyRoom::STATIC_PACKET)
    pc.send_packet(SystemMessageId::PARTY_ROOM_EXITED)
  end
end
