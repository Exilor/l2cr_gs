class Condition
  class PlayerIsHero < Condition
    initializer val: Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player?
      pc.hero? == @val
    end
  end
end
