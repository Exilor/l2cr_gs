require "../../../models/party_match_room"

class Packets::Outgoing::ExManagePartyRoomMember < GameServerPacket
  initializer pc : L2PcInstance, room : PartyMatchRoom, mode : Int32

  private def write_impl
    c 0xfe
    h 0x0a

    d @mode
    d @pc.l2id
    s @pc.name
    d @pc.active_class
    d @pc.level
    d @room.location
    if @room.owner == @pc
      d 1
    else
      if @room.owner.party && @pc.party && @room.owner.party == @pc.party
        d 0x02
        return
      end

      d 0x00
    end
  end
end
