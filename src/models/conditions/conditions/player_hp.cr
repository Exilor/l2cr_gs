class Condition
  class PlayerHp < self
    initializer hp : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effector.hp_percent <= @hp
    end
  end
end
