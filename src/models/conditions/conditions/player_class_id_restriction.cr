require "../../../enums/class_id"

class Condition
  class PlayerClassIdRestriction < Condition
    initializer class_ids: Array(Int32)

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effector.acting_player? &&
      @class_ids.includes?(effector.acting_player.class_id.to_i)
    end
  end
end
