module GameDB
  module PlayerDAO
    include Loggable

    abstract def load(l2id : Int32) : L2PcInstance?
  end
end
