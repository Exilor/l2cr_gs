class Packets::Outgoing::ChairSit < GameServerPacket
  initializer pc : L2PcInstance, static_l2id : Int32

  def write_impl
    c 0xed

    d @pc.l2id
    d @static_l2id
  end
end
