class Packets::Outgoing::ExCubeGameChangeTeam < GameServerPacket
  initializer pc: L2PcInstance, from_red: Bool

  def write_impl
    c 0xfe
    h 0x97

    d 0x05

    d @pc.l2id
    d @from_red ? 1 : 0
    d @from_red ? 0 : 1
  end
end
