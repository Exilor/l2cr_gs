class Packets::Outgoing::ExPartyRoomMember < GameServerPacket
  initializer room: PartyMatchRoom, mode: Int32

  def write_impl
    c 0xfe
    h 0x08

    d @mode
    d @room.members
    @room.party_members.each do |m|
      d m.l2id
      s m.name
      d m.active_class
      d m.level
      d @room.location
      if @room.owner == m
        d 0x01
      else
        owner = @room.owner
        if owner.in_party? && m.in_party? && owner.party.leader_l2id == m.party.leader_l2id
          d 0x02
        else
          d 0x00
        end
      end
      d 0x00 # L2J TODO, instance stuff
    end
  end
end
