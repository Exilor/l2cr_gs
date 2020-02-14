require "../../../enums/class_id"

class Condition
  class PlayerClassIdRestriction < Condition
    @class_ids : Slice(Int32)

    def initialize(class_ids)
      @class_ids = class_ids.sort.to_slice
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      @class_ids.bincludes?(pc.class_id.to_i)
    end
  end
end
