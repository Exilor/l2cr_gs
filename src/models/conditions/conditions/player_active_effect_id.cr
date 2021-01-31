class Condition
  class PlayerActiveEffectId < self
    initializer id : Int32, lvl : Int32 = -1

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      buff = effector.effect_list.get_buff_info_by_skill_id(@id)
      !!buff && (@lvl == -1 || @lvl <= buff.skill.level)
    end
  end
end
