class Condition
  class PlayerLevel < Condition
    initializer level : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effector.level >= @level
    end
  end
end
