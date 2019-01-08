class Condition
  class PlayerLandingZone < Condition
    initializer val: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effector.inside_landing_zone? == @val
    end
  end
end
