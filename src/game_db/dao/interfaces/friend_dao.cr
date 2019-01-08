module GameDB
  module FriendDAO
    include Loggable

    abstract def load(pc : L2PcInstance)
  end
end
