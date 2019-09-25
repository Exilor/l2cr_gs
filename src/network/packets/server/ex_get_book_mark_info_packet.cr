class Packets::Outgoing::ExGetBookMarkInfoPacket < GameServerPacket
  initializer pc : L2PcInstance

  def write_impl
    c 0xfe
    h 0x84

    d 0
    d @pc.bookmark_slot
    d @pc.teleport_bookmarks.size
    @pc.teleport_bookmarks.each do |tp|
      d tp.id
      l tp
      s tp.name
      d tp.icon
      s tp.tag
    end
  end
end
