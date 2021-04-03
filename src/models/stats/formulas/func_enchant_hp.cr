class FuncEnchantHp < AbstractFunction
  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    if test(effector, effected, skill)
      owner = @owner.as(L2ItemInstance)
      if owner.enchant_level > 0
        return value + EnchantItemHPBonusData.get_hp_bonus(owner)
      end
    end

    value
  end
end
