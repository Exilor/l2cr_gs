class FuncEnchantHp < AbstractFunction
  def calc(effector, effected, skill, value)
    if test(effector, effected, skill)
      owner = @owner.as(L2ItemInstance)
      if owner.enchant_level > 0
        return value + EnchantItemHPBonusData.get_hp_bonus(owner)
      end
    end

    value
  end
end
