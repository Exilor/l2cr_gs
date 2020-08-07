class Packets::Outgoing::FriendPacket < GameServerPacket
  @online : Bool

  def initialize(action : Bool, obj_id : Int32)
    @action = action
    @obj_id = obj_id
    @name = CharNameTable.get_name_by_id(obj_id)
    @online = !!L2World.get_player(obj_id)
  end

  private def write_impl
    c 0x76

    d @action ? 1 : 3
    d @obj_id
    s @name
    d @online ? 1 : 0
    d @online ? @obj_id : 0
  end
end
