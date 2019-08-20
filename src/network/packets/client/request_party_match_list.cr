class Packets::Incoming::RequestPartyMatchList < GameClientPacket
  @room_id = 0
  @max_members = 0
  @min_lvl = 0
  @max_lvl = 0
  @loot = 0
  @room_title = ""

  private def read_impl
    @room_id = d
    @max_members = d
    @min_lvl = d
    @max_lvl = d
    @loot = d
    @room_title = s
  end

  private def run_impl
    return unless pc = active_char

    if @room_id > 0
      if room = PartyMatchRoomList.get_room(@room_id)
        debug "PartyMatchRoom ##{room.id} changed by #{pc.name}."
        room.max_members = @max_members
        room.min_lvl = @min_lvl
        room.max_lvl = @max_lvl
        room.loot_type = @loot
        room.title = @room_title

        room.party_members.each do |m|
          m.send_packet(PartyMatchDetail.new(room))
          m.send_packet(SystemMessageId::PARTY_ROOM_REVISED)
        end
      end
    else
      max_id = PartyMatchRoomList.max_id
      room = PartyMatchRoom.new(max_id, @room_title, @loot, @min_lvl, @max_lvl, @max_members, pc)
      info { "PartyMatchRoom ##{max_id} created by #{pc.name}." }
      PartyMatchWaitingList.remove_player(pc)
      PartyMatchRoomList.add_party_match_room(max_id, room)

      if party = pc.party?
        party.each do |m|
          next if m == pc
          m.party_room = max_id
          room.add_member m
        end
      end

      pc.send_packet(PartyMatchDetail.new(room))
      pc.send_packet(ExPartyRoomMember.new(room, 1))
      pc.send_packet(SystemMessageId::PARTY_ROOM_CREATED)
      pc.party_room = max_id
      pc.broadcast_user_info
    end
  end
end
