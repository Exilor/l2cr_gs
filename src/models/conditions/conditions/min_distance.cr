class Condition
  class MinDistance < Condition
    initializer dist: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effected && effector.calculate_distance(effected, true, true) >= @dist
    end
  end
end
