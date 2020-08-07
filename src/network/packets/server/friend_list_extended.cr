class Packets::Outgoing::FriendListExtended < GameServerPacket
  private record FriendInfo, l2id : Int32, name : String, online : Bool,
    class_id : Int32, level : Int32

  @friends : Array(FriendInfo)?

  def initialize(pc : L2PcInstance)
    unless pc.has_friends?
      return
    end

    friends = [] of FriendInfo

    pc.friends.each do |obj_id|
      unless name = CharNameTable.get_name_by_id(obj_id)
        warn { "Name for player with object id #{obj_id} not found in CharNameTable." }
        next
      end

      friend = L2World.get_player(obj_id)
      unless friend
        begin
          sql = "SELECT char_name, online, classid, level FROM characters WHERE charId = ?"
          GameDB.each(sql, obj_id) do |rs|
            char_name = rs.get_string(:"char_name")
            online = rs.get_i32(:"online") == 0
            class_id = rs.get_i32(:"classid")
            level = rs.get_i32(:"level")

            info = FriendInfo.new(obj_id, char_name, online, class_id, level)
            friends << info
          end
        rescue e
          error e
        end

        next
      end

      online = friend.online?
      class_id = friend.class_id.to_i
      level = friend.level
      friends << FriendInfo.new(obj_id, name, online, class_id, level)
    end

    @friends = friends
  end

  private def write_impl
    c 0x58

    if friends = @friends
      d friends.size
      friends.each do |friend|
        d friend.l2id
        s friend.name
        d friend.online ? 1 : 0
        d friend.online ? friend.l2id : 0
        d friend.class_id
        d friend.level
      end
    else
      d 0
    end
  end
end
