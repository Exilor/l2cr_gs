class Condition
  class UsingSkill < Condition
    initializer id : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless skill
      skill.id == @id
    end
  end
end
