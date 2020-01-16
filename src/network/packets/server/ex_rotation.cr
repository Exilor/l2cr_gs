class Packets::Outgoing::ExRotation < GameServerPacket
  initializer char_id : Int32, heading : Int32

  private def write_impl
    c 0xfe
    h 0xc1

    d @char_id
    d @heading
  end
end
