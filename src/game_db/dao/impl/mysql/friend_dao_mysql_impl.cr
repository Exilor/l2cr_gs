module GameDB
  module FriendDAOMySQLImpl
    extend self
    extend FriendDAO

    private SELECT = "SELECT friendId FROM character_friends WHERE charId=? AND relation=0 AND friendId<>charId"
    private INSERT = "INSERT INTO character_friends (charId, friendId) VALUES (?, ?), (?, ?)"
    private DELETE = "DELETE FROM character_friends WHERE (charId=? AND friendId=?) OR (charId=? AND friendId=?)"

    def load(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id) do |rs|
        pc.add_friend(rs.get_i32(:"friendId"))
      end
    rescue e
      error e
    end

    def insert(pc : L2PcInstance, friend : L2PcInstance)
      GameDB.exec(INSERT, friend.l2id, pc.l2id, pc.l2id, friend.l2id)
    rescue e
      error e
    end

    def delete(pc : L2PcInstance, friend_id : Int32)
      GameDB.exec(DELETE, pc.l2id, friend_id, friend_id, pc.l2id)
    rescue e
      error e
    end
  end
end
