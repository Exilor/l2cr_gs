class Condition
  class PlayerHp < Condition
    initializer hp : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effector
      (effector.current_hp * 100) / effector.max_hp <= @hp
    end
  end
end
