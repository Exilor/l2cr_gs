class Condition
  class PlayerActiveSkillId < Condition
    def initialize(@id : Int32, @lvl : Int32 = -1)
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effector.skills.each_value do |sk|
        if sk.id == @id
          return true if @lvl == -1 || @lvl <= sk.level
        end
      end

      false
    end
  end
end
