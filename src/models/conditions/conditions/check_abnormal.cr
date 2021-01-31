require "../../../enums/abnormal_type"

class Condition
  class CheckAbnormal < self
    initializer type : AbnormalType, level : Int32, must_have : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      info = effector.effect_list.get_buff_info_by_abnormal_type(@type)
      return !@must_have unless info
      @level == -1 || @level >= info.skill.abnormal_lvl
    end
  end
end
