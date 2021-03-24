module GameDB
  module SubclassDAO
    macro extended
      include Loggable
    end

    abstract def update(pc : L2PcInstance)
    abstract def insert(pc : L2PcInstance, new_class : Subclass) : Bool
    abstract def delete(pc : L2PcInstance, class_index : Int32)
    abstract def load(pc : L2PcInstance)
  end
end
