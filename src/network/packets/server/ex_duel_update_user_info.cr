class Packets::Outgoing::ExDuelUpdateUserInfo < GameServerPacket
  initializer pc: L2PcInstance

  def write_impl
    c 0xfe
    h 0x50

    s @pc.name
    d @pc.l2id
    d @pc.class_id.to_i
    d @pc.level
    d @pc.current_hp.to_i
    d @pc.max_hp
    d @pc.current_mp.to_i
    d @pc.max_mp
    d @pc.current_cp.to_i
    d @pc.max_cp
  end
end
