class Packets::Outgoing::FriendList < GameServerPacket
  private record FriendInfo, l2id : Int32, name : String, online : Bool

  @info : Array(FriendInfo)?

  def initialize(pc : L2PcInstance)
    if pc.has_friends?
      info = Array(FriendInfo).new(pc.friends.size)
      pc.friends.each do |id|
        name = CharNameTable.get_name_by_id(id).not_nil!
        friend = L2World.get_player(id)
        info << FriendInfo.new(id, name, !!friend && friend.online?)
      end
      @info = info
    end
  end

  private def write_impl
    c 0x75

    if infos = @info
      d infos.size
      infos.each do |info|
        d info.l2id
        s info.name
        d info.online ? 1 : 0
        d info.online ? info.l2id : 0
      end
    else
      d 0
    end
  end
end
