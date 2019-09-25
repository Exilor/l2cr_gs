class Packets::Outgoing::PremiumState < GameServerPacket
  initializer l2id : Int32, state : Int32

  def write_impl
    c 0xfe
    h 0xaa

    d @l2id
    c @state
  end
end
