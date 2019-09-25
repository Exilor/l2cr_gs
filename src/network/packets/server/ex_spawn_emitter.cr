class Packets::Outgoing::ExSpawnEmitter < GameServerPacket
  initializer pc_id : Int32, npc_id : Int32

  def initialize(pc : L2PcInstance, npc : L2Npc)
    initialize(pc.l2id, npc.l2id)
  end

  def write_impl
    c 0xfe
    h 0x5d

    d @npc_id
    d @pc_id
    d 0x00
  end
end
