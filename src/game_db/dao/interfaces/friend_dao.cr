module GameDB
  module FriendDAO
    include Loggable

    abstract def load(pc : L2PcInstance)
    abstract def insert(pc : L2PcInstance, friend : L2PcInstance)
    abstract def delete(pc : L2PcInstance, friend_id : Int32)
  end
end
