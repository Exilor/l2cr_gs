class Packets::Incoming::RequestFriendDel < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    return unless pc = active_char

    id = CharNameTable.get_id_by_name(@name)

    if id == -1
      sm = SystemMessage.c1_not_on_your_friends_list
      sm.add_string(@name)
      pc.send_packet(sm)
      return
    end

    begin
      sql = "DELETE FROM character_friends WHERE (charId=? AND friendId=?) OR (charId=? AND friendId=?)"
      GameDB.exec(
        sql,
        pc.l2id,
        id,
        id,
        pc.l2id
      )
    rescue e
      error e
    end

    sm = SystemMessage.s1_has_been_deleted_from_your_friends_list
    sm.add_string(@name)
    pc.send_packet(sm)

    pc.remove_friend(id)
    pc.send_packet(FriendPacket.new(false, id))

    if friend = L2World.get_player(@name)
      friend.remove_friend(pc.l2id)
      friend.send_packet(FriendPacket.new(false, pc.l2id))
    end
  end
end
