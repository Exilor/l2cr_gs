class Packets::Outgoing::ExBrPremiumState < GameServerPacket
  initializer id : Int32, state : Int8

  private def write_impl
    c 0xfe
    h 0xd9

    d @id
    c @state
  end
end
