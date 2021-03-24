module GameDB
  module PlayerSkillSaveDAO
    macro extended
      include Loggable
    end

    abstract def delete(pc : L2PcInstance, class_id : Int32)
    abstract def delete(pc : L2PcInstance)
    abstract def insert(pc : L2PcInstance, store_effects : Bool)
    abstract def load(pc : L2PcInstance)
  end
end
