class Packets::Outgoing::FriendStatusPacket < GameServerPacket
  @online : Bool

  def initialize(@l2id : Int32)
    @name = CharNameTable.get_name_by_id(l2id)
    @online = !!L2World.get_player(l2id)
  end

  private def write_impl
    c 0x77

    d @online ? 1 : 0
    s @name
    d @l2id
  end
end
