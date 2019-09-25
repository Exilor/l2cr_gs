class Condition
  class GameChance < Condition
    initializer chance : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      Rnd.rand(100) < @chance
    end
  end
end
