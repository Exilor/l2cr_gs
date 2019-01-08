class Packets::Incoming::RequestPartyMatchDetail < GameClientPacket
  @room_id = 0

  def read_impl
    @room_id = d
    # @unk1, @unk2, @unk3 = d, d, d
  end

  def run_impl
    return unless pc = active_char
    return unless room = PartyMatchRoomList.get_room(@room_id)

    if pc.level >= room.min_lvl && pc.level <= room.max_lvl
      PartyMatchWaitingList.remove_player(pc)
      pc.party_room = @room_id
      pc.send_packet(PartyMatchDetail.new(room))
      pc.send_packet(ExPartyRoomMember.new(room, 0))

      room.party_members.each do |m|
        m.send_packet(ExManagePartyRoomMember.new(pc, room, 0))
        sm = SystemMessage.c1_entered_party_room
        sm.add_char_name(pc)
        m.send_packet(sm)
      end
      room.add_member(pc)
      pc.broadcast_user_info
    else
      pc.send_packet(SystemMessageId::CANT_ENTER_PARTY_ROOM)
    end
  end
end
