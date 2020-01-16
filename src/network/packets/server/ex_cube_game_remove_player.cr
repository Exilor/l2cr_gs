class Packets::Outgoing::ExCubeGameRemovePlayer < GameServerPacket
  initializer pc : L2PcInstance, red_team : Bool

  private def write_impl
    c 0xfe
    h 0x97

    d 0x02
    d 0xffffffff

    d @red_team ? 1 : 0
    d @pc.l2id
  end
end
