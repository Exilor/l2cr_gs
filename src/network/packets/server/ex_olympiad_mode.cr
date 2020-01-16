class Packets::Outgoing::ExOlympiadMode < GameServerPacket
  initializer mode : Int32

  private def write_impl
    c 0xfe
    h 0x7c

    c @mode
  end
end
