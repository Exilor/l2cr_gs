class Packets::Outgoing::PartyMatchDetail < GameServerPacket
  initializer room : PartyMatchRoom

  private def write_impl
    c 0x9d

    d @room.id
    d @room.max_members
    d @room.min_lvl
    d @room.max_lvl
    d @room.loot_type
    d @room.location
    s @room.title
    h 59064 # ?
  end
end
