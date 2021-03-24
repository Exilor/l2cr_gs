module GameDB
  module PlayerDAO
    macro extended
      include Loggable
    end

    abstract def load(l2id : Int32) : L2PcInstance?
  end
end
