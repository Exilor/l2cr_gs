class Packets::Outgoing::ExFishingHpRegen < GameServerPacket
  initializer pc : L2Character, time : Int32, hp : Int32, hp_mode : Int32,
    good_use : Int32, anim : Int32, penalty : Int32, color : Int32

  def write_impl
    c 0xfe
    h 0x28

    d @pc.l2id
    d @time
    d @hp
    c @hp_mode # 0 = HP stop, 1 = HP raise
    c @good_use # 0 = none, 1 = success, 2 = failed
    c @anim # Anim: 0 = none, 1 = reeling, 2 = pumping
    d @penalty
    c @color # 0 = normal hp bar, 1 = purple hp bar
  end
end
