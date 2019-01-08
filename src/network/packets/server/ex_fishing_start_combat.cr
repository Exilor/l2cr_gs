class Packets::Outgoing::ExFishingStartCombat < GameServerPacket
  initializer pc: L2Character, time: Int32, hp: Int32, mode: Int32, lure: Int32,
    deceptive: Int32

  def write_impl
    c 0xfe
    h 0x27

    d @pc.l2id
    d @time
    d @hp
    c @mode
    c @lure
    c @deceptive
  end
end
