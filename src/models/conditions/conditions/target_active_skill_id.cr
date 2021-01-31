class Condition
  class TargetActiveSkillId < self
    initializer id : Int32, lvl : Int32 = -1

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effected.try &.skills.each_value do |sk|
        if sk.id == @id
          return true if @lvl == -1 || @lvl <= sk.level
        end
      end

      false
    end
  end
end
