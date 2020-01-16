class Packets::Outgoing::ExRedSky < GameServerPacket
  initializer duration : Int32

  private def write_impl
    c 0xfe
    h 0x41

    d @duration
  end
end
