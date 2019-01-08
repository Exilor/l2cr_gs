class Packets::Outgoing::Ride < GameServerPacket
  @l2id : Int32
  @ride_type : Int32
  @ride_npc_id : Int32
  @loc : Location

  def initialize(pc : L2PcInstance)
    @l2id = pc.l2id
    @mounted = pc.mounted? ? 1 : 0
    @ride_type = pc.mount_type.to_i
    @ride_npc_id = pc.mount_npc_id + 1_000_000
    @loc = pc.location
  end

  def write_impl
    c 0x8c

    d @l2id
    d @mounted
    d @ride_type
    d @ride_npc_id
    l @loc
  end
end
