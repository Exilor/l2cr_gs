class Packets::Outgoing::PartySmallWindowUpdate < GameServerPacket
  initializer pc : L2PcInstance

  private def write_impl
    c 0x52

    d @pc.l2id
    s @pc.name

    d @pc.current_cp
    d @pc.max_cp
    d @pc.current_hp
    d @pc.max_hp
    d @pc.current_mp
    d @pc.max_mp
    d @pc.level
    d @pc.class_id.to_i
  end
end
