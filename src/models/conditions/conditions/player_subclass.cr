class Condition
  class PlayerSubclass < Condition
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return true unless pc = effector.acting_player?
      pc.subclass_active? == @val
    end
  end
end
