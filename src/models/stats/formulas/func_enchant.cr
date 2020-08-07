class FuncEnchant < AbstractFunction
  def calc(effector, effected, skill, value)
    return value unless test(effector, effected, skill)

    item = @owner.as(L2ItemInstance)

    enchant = item.enchant_level
    return value if enchant <= 0

    overenchant = 0

    if enchant > 3
      overenchant = enchant &- 3
      enchant = 3
    end

    if effector.is_a?(L2PcInstance)
      if effector.in_olympiad_mode? && Config.alt_oly_enchant_limit >= 0
        if enchant &+ overenchant > Config.alt_oly_enchant_limit
          if Config.alt_oly_enchant_limit > 3
            overenchant = Config.alt_oly_enchant_limit &- 3
          else
            overenchant = 0
            enchant = Config.alt_oly_enchant_limit
          end
        end
      end
    end

    if @stat.magic_defence? || @stat.power_defence?
      return value + enchant + (3 &* overenchant)
    end

    if @stat.magic_attack?
      case item.template.item_grade_s_plus
      when CrystalType::S
        value += (4 &* enchant) &+ (8 &* overenchant)
      when CrystalType::A, CrystalType::B, CrystalType::C
        value += (3 &* enchant) &+ (6 &* overenchant)
      when CrystalType::D, CrystalType::NONE
        value += (2 &* enchant) &+ (4 &* overenchant)
      end

      return value
    end

    if item.weapon?
      type = item.item_type.as(WeaponType)
      case item.template.item_grade_s_plus
      when CrystalType::S
        if item.weapon_item!.body_part == L2Item::SLOT_LR_HAND
          if type.bow? || type.crossbow?
            value += (10 &* enchant) &+ (20 &* overenchant)
          else
            value += (6 &* enchant) &+ (12 &* overenchant)
          end
        else
          value += (5 &* enchant) &+ (10 &* overenchant)
        end
      when CrystalType::A
        if item.weapon_item!.body_part == L2Item::SLOT_LR_HAND
          if type.bow? || type.crossbow?
            value += (8 &* enchant) &+ (16 &* overenchant)
          else
            value += (5 &* enchant) &+ (10 &* overenchant)
          end
        else
          value += (4 &* enchant) &+ (8 &* overenchant)
        end
      when CrystalType::B, CrystalType::C
        if item.weapon_item!.body_part == L2Item::SLOT_LR_HAND
          if type.bow? || type.crossbow?
            value += (6 &* enchant) &+ (12 &* overenchant)
          else
            value += (4 &* enchant) &+ (8 &* overenchant)
          end
        else
          value += (3 &* enchant) &+ (6 &* overenchant)
        end
      when CrystalType::D, CrystalType::NONE
        if type.bow? || type.crossbow?
          value += (4 &* enchant) &+ (8 &* overenchant)
        else
          value += (2 &* enchant) &+ (4 &* overenchant)
        end
      end
    end

    value
  end
end
