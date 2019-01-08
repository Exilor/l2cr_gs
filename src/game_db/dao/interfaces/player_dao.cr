module GameDB
  module PlayerDAO
    abstract def load(l2id : Int32) : L2PcInstance?
  end
end
