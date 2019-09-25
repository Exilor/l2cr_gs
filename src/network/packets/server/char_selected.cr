class Packets::Outgoing::CharSelected < GameServerPacket
  initializer pc : L2PcInstance, session_id : Int32

  def write_impl
    c 0x0b

    s @pc.name
    d @pc.l2id
    s @pc.title
    d @session_id
    d @pc.clan_id
    d 0x00 # unknown
    d @pc.appearance.sex ? 1 : 0
    d @pc.race.to_i
    d @pc.class_id.to_i
    d 0x01 # unknown
    l @pc

    f @pc.current_hp
    f @pc.current_mp
    d @pc.sp
    q @pc.exp
    d @pc.level
    d @pc.karma
    d @pc.pk_kills
    d @pc.int
    d @pc.str
    d @pc.con
    d @pc.men
    d @pc.dex
    d @pc.wit

    d GameTimer.time % (24 * 60)
    d 0x00

    d @pc.class_id.to_i

    d 0x00
    d 0x00
    d 0x00
    d 0x00

    temp = uninitialized UInt8[64]
    b temp.to_slice
    d 0x00 # unknown
  end
end
