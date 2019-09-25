class Condition
  class PlayerFlyMounted < Condition
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return true unless effector.acting_player?
      effector.acting_player.flying_mounted? == @val
    end
  end
end
