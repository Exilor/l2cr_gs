class Packets::Outgoing::ListPartyWating < GameServerPacket
  def initialize(@pc : L2PcInstance, auto, @loc : Int32, @lim : Int32) # what about 'auto'?
  end

  def write_impl
    rooms = [] of PartyMatchRoom

    PartyMatchRoomList.rooms.each do |room|
      if room.members < 1 || room.owner.nil? || !room.owner.online? || room.owner.party_room != room.id
        PartyMatchRoomList.delete_room(room.id)
        next
      end

      if @loc > 0 && @loc != room.location
        next
      end

      if @lim == 0 && (@pc.level < room.min_lvl || @pc.level > room.max_lvl)
        next
      end

      rooms << room
    end

    size = rooms.size

    c 0x9c
    d size > 0 ? 0x01 : 0x00
    d rooms.size
    rooms.each do |room|
      d room.id
      s room.title
      d room.location
      d room.min_lvl
      d room.max_lvl
      d room.max_members
      s room.owner.name
      d room.members
      room.party_members.each do |m|
        if m
          d m.class_id.to_i
          s m.name
        else
          d 0x00
          s "Not Found"
        end
      end
    end
  end
end
