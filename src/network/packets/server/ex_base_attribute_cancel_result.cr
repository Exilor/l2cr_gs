class Packets::Outgoing::ExBaseAttributeCancelResult < GameServerPacket
  initializer l2id : Int32, attribute : Int8

  def write_impl
    c 0xfe
    h 0x75

    d 0x01
    d @l2id
    d @attribute
  end
end
