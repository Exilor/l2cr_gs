class Packets::Outgoing::ExChangeNpcState < GameServerPacket
  initializer id : Int32, state : Int32

  private def write_impl
    c 0xfe
    h 0xbe

    d @id
    d @state
  end
end
