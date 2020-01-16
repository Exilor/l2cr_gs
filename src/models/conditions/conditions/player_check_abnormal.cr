require "../../../enums/abnormal_type"

class Condition
  class PlayerCheckAbnormal < Condition
    initializer type : AbnormalType, level : Int32 = -1

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      info = effector.effect_list.get_buff_info_by_abnormal_type(@type)
      !!info && (@level == -1 || @level >= info.skill.abnormal_lvl)
    end
  end
end
