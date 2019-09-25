class Packets::Outgoing::ExFishingEnd < GameServerPacket
  initializer win : Bool, pc : L2PcInstance

  def write_impl
    c 0xfe
    h 0x1f

    d @pc.l2id
    c @win ? 1 : 0
  end
end
