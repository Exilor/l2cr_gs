class FuncEnchantHp < AbstractFunction
  def calc(effector, effected, skill, val)
    if test(effector, effected, skill)
      owner = @owner.as(L2ItemInstance)
      if owner.enchant_level > 0
        val + EnchantItemHPBonusData.get_hp_bonus(owner)
      else
        val
      end
    else
      val
    end
  end
end
