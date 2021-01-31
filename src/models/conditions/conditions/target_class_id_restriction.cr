require "../../../enums/class_id"

class Condition
  class TargetClassIdRestriction < self
    @class_ids : Slice(Int32)
    def initialize(class_ids)
      @class_ids = class_ids.sort.to_slice
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effected.is_a?(L2PcInstance) &&
      @class_ids.bincludes?(effected.class_id.to_i)
    end
  end
end
