class Packets::Outgoing::ExFishingStart < GameServerPacket
  initializer pc : L2PcInstance, type : Int32, x : Int32, y : Int32, z : Int32,
    night_lure : Bool

  private def write_impl
    c 0xfe
    h 0x1e

    d @pc.l2id
    d @type
    d @x
    d @y
    d @z
    c @night_lure ? 1 : 0
    c 0 # show fish rank result button
  end
end
