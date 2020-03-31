class Packets::Outgoing::ExRotation < GameServerPacket
  initializer l2id : Int32, heading : Int32

  private def write_impl
    c 0xfe
    h 0xc1

    d @l2id
    d @heading
  end
end
