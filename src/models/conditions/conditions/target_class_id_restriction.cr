require "../../../enums/class_id"

class Condition
  class TargetClassIdRestriction < Condition
    initializer class_ids : Array(Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effected.is_a?(L2PcInstance) &&
      @class_ids.includes?(effected.class_id.to_i)
    end
  end
end
