class Packets::Outgoing::PartySmallWindowDelete < GameServerPacket
  initializer pc : L2PcInstance

  private def write_impl
    c 0x51

    d @pc.l2id
    s @pc.name
  end
end
