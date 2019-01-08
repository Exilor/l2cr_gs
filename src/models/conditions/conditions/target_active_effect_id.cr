class Condition
  class TargetActiveEffectId < Condition
    def initialize(@id : Int32, @lvl : Int32 = -1)
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      info = effected.try &.effect_list.get_buff_info_by_skill_id(@id)
      !!info && (@lvl == -1 || @lvl <= info.skill.level)
    end
  end
end
