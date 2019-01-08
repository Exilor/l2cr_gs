module GameDB
  module ItemReuseDAO
    include Loggable

    abstract def load(pc : L2PcInstance)
    abstract def insert(pc : L2PcInstance)
    abstract def delete(pc : L2PcInstance)
  end
end
