module GameDB
  module HennaDAO
    macro extended
      include Loggable
    end

    abstract def load(pc : L2PcInstance)
    abstract def insert(pc : L2PcInstance, henna : L2Henna, slot : Int32)
    abstract def delete(pc : L2PcInstance, slot : Int32)
    abstract def delete_all(pc : L2PcInstance, class_index : Int32)
  end
end
