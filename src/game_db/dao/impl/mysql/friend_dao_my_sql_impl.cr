module GameDB
  module FriendDAOMySQLImpl
    extend self
    extend FriendDAO

    private SELECT = "SELECT friendId FROM character_friends WHERE charId=? AND relation=0 AND friendId<>charId"

    def load(pc : L2PcInstance)
      GameDB.each(SELECT, pc.l2id) do |rs|
        pc.add_friend(rs.get_i32("friendId"))
      end
    rescue e
      error e
    end
  end
end
