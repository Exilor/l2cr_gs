module PartyMatchRoomList
  extend self
  extend Synchronizable

  private ROOMS = Hash(Int32, PartyMatchRoom).new

  class_getter max_id = 1

  def add_party_match_room(id : Int32, room : PartyMatchRoom)
    sync do
      ROOMS[id] = room
      @@max_id += 1
    end
  end

  def delete_room(id : Int32)
    get_room(id).try &.party_members.each do |m|
      m.send_packet(Packets::Outgoing::ExClosePartyRoom::STATIC_PACKET)
      m.send_packet(SystemMessageId::PARTY_ROOM_DISBANDED)
      m.party_room = 0
      m.broadcast_user_info
    end

    ROOMS.delete(id)
  end

  def get_room(id : Int32) : PartyMatchRoom?
    ROOMS[id]?
  end

  def rooms : Enumerable(PartyMatchRoom)
    ROOMS.local_each_value
  end

  def party_match_room_count : Int32
    ROOMS.size
  end

  def get_player_room(pc : L2PcInstance) : PartyMatchRoom?
    ROOMS.find_value &.party_members.includes?(pc)
  end

  def get_player_room_id(pc : L2PcInstance) : Int32
    get_player_room(pc).try &.id || -1
  end
end
