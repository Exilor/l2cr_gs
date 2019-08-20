class Stats < EnumClass
  getter value
  getter? check_negative

  protected def initialize(@value : String, @check_negative : Bool = false)
  end

  def self.from_value(str : String) : self
    find { |stat| stat.value == str } ||
    raise("No member with value #{str.inspect} found")
  end

  # HP, MP & CP
  add(MAX_HP, "maxHp", true)
  add(MAX_MP, "maxMp", true)
  add(MAX_CP, "maxCp", true)
  add(MAX_RECOVERABLE_HP, "maxRecoverableHp") # The maximum HP that is able to be recovered through heals
  add(MAX_RECOVERABLE_MP, "maxRecoverableMp")
  add(MAX_RECOVERABLE_CP, "maxRecoverableCp")
  add(REGENERATE_HP_RATE, "regHp")
  add(REGENERATE_CP_RATE, "regCp")
  add(REGENERATE_MP_RATE, "regMp")
  add(MANA_CHARGE, "manaCharge")
  add(HEAL_EFFECT, "healEffect")

  # ATTACK & DEFENCE
  add(POWER_DEFENCE, "pDef", true)
  add(MAGIC_DEFENCE, "mDef", true)
  add(POWER_ATTACK, "pAtk", true)
  add(MAGIC_ATTACK, "mAtk", true)
  add(PHYSICAL_SKILL_POWER, "physicalSkillPower")
  add(POWER_ATTACK_SPEED, "pAtkSpd", true)
  add(MAGIC_ATTACK_SPEED, "mAtkSpd", true) # Magic Skill Casting Time Rate
  add(ATK_REUSE, "atkReuse") # Bows Hits Reuse Rate
  add(P_REUSE, "pReuse") # Physical Skill Reuse Rate
  add(MAGIC_REUSE_RATE, "mReuse") # Magic Skill Reuse Rate
  add(DANCE_REUSE, "dReuse") # Dance Skill Reuse Rate
  add(SHIELD_DEFENCE, "sDef", true)

  add(CRITICAL_DAMAGE, "critDmg")
  add(CRITICAL_DAMAGE_POS, "critDmgPos")
  add(CRITICAL_DAMAGE_ADD, "critDmgAdd") # this is another type for special critical damage mods - vicious stance, critical power and critical damage SA
  add(MAGIC_CRIT_DMG, "mCritPower")

  # PVP BONUS
  add(PVP_PHYSICAL_DMG, "pvpPhysDmg")
  add(PVP_MAGICAL_DMG, "pvpMagicalDmg")
  add(PVP_PHYS_SKILL_DMG, "pvpPhysSkillsDmg")
  add(PVP_PHYSICAL_DEF, "pvpPhysDef")
  add(PVP_MAGICAL_DEF, "pvpMagicalDef")
  add(PVP_PHYS_SKILL_DEF, "pvpPhysSkillsDef")

  # PVE BONUS
  add(PVE_PHYSICAL_DMG, "pvePhysDmg")
  add(PVE_PHYS_SKILL_DMG, "pvePhysSkillsDmg")
  add(PVE_BOW_DMG, "pveBowDmg")
  add(PVE_BOW_SKILL_DMG, "pveBowSkillsDmg")
  add(PVE_MAGICAL_DMG, "pveMagicalDmg")

  # ATTACK & DEFENCE RATES
  add(EVASION_RATE, "rEvas")
  add(P_SKILL_EVASION, "pSkillEvas")
  add(DEFENCE_CRITICAL_RATE, "defCritRate")
  add(DEFENCE_CRITICAL_RATE_ADD, "defCritRateAdd")
  add(DEFENCE_CRITICAL_DAMAGE, "defCritDamage")
  add(DEFENCE_CRITICAL_DAMAGE_ADD, "defCritDamageAdd") # Resistance to critical damage in value (Example: +100 will be 100 more critical damage, NOT 100% more).
  add(SHIELD_RATE, "rShld")
  add(CRITICAL_RATE, "critRate")
  add(CRITICAL_RATE_POS, "critRatePos")
  add(BLOW_RATE, "blowRate")
  add(MCRITICAL_RATE, "mCritRate")
  add(EXPSP_RATE, "rExp")
  add(BONUS_EXP, "bonusExp")
  add(BONUS_SP, "bonusSp")
  add(ATTACK_CANCEL, "cancel")

  # ACCURACY & RANGE
  add(ACCURACY_COMBAT, "accCombat")
  add(POWER_ATTACK_RANGE, "pAtkRange")
  add(MAGIC_ATTACK_RANGE, "mAtkRange")
  add(ATTACK_COUNT_MAX, "atkCountMax")
  # Run speed, walk & escape speed are calculated proportionally, magic speed is a buff
  add(MOVE_SPEED, "runSpd")

  # BASIC STATS
  add(STAT_STR, "STR", true)
  add(STAT_CON, "CON", true)
  add(STAT_DEX, "DEX", true)
  add(STAT_INT, "INT", true)
  add(STAT_WIT, "WIT", true)
  add(STAT_MEN, "MEN", true)

  # Special stats, share one slot in Calculator

  # VARIOUS
  add(BREATH, "breath")
  add(FALL, "fall")

  # VULNERABILITIES
  add(DAMAGE_ZONE_VULN, "damageZoneVuln")
  add(MOVEMENT_VULN, "movementVuln")
  add(CANCEL_VULN, "cancelVuln") # Resistance for cancel type skills
  add(DEBUFF_VULN, "debuffVuln")
  add(BUFF_VULN, "buffVuln")

  # RESISTANCES
  add(FIRE_RES, "fireRes")
  add(WIND_RES, "windRes")
  add(WATER_RES, "waterRes")
  add(EARTH_RES, "earthRes")
  add(HOLY_RES, "holyRes")
  add(DARK_RES, "darkRes")
  add(MAGIC_SUCCESS_RES, "magicSuccRes")
  # BUFF_IMMUNITY("buffImmunity") #TODO: Implement me
  add(DEBUFF_IMMUNITY, "debuffImmunity")

  # ELEMENT POWER
  add(FIRE_POWER, "firePower")
  add(WATER_POWER, "waterPower")
  add(WIND_POWER, "windPower")
  add(EARTH_POWER, "earthPower")
  add(HOLY_POWER, "holyPower")
  add(DARK_POWER, "darkPower")

  # PROFICIENCY
  add(CANCEL_PROF, "cancelProf")

  add(REFLECT_DAMAGE_PERCENT, "reflectDam")
  add(REFLECT_SKILL_MAGIC, "reflectSkillMagic")
  add(REFLECT_SKILL_PHYSIC, "reflectSkillPhysic")
  add(VENGEANCE_SKILL_MAGIC_DAMAGE, "vengeanceMdam")
  add(VENGEANCE_SKILL_PHYSICAL_DAMAGE, "vengeancePdam")
  add(ABSORB_DAMAGE_PERCENT, "absorbDam")
  add(TRANSFER_DAMAGE_PERCENT, "transDam")
  add(MANA_SHIELD_PERCENT, "manaShield")
  add(TRANSFER_DAMAGE_TO_PLAYER, "transDamToPlayer")
  add(ABSORB_MANA_DAMAGE_PERCENT, "absorbDamMana")

  add(WEIGHT_LIMIT, "weightLimit")
  add(WEIGHT_PENALTY, "weightPenalty")
  add(ENLARGE_ABNORMAL_SLOT, "enlargeAbnormalSlot")

  # ExSkill
  add(INV_LIM, "inventoryLimit")
  add(WH_LIM, "whLimit")
  add(FREIGHT_LIM, "freightLimit")
  add(P_SELL_LIM, "privateSellLimit")
  add(P_BUY_LIM, "privateBuyLimit")
  add(REC_D_LIM, "dwarfRecipeLimit")
  add(REC_C_LIM, "commonRecipeLimit")

  # C4 Stats
  add(PHYSICAL_MP_CONSUME_RATE, "physicalMpConsumeRate")
  add(MAGICAL_MP_CONSUME_RATE, "magicalMpConsumeRate")
  add(DANCE_MP_CONSUME_RATE, "danceMpConsumeRate")
  add(BOW_MP_CONSUME_RATE, "bowMpConsumeRate")
  add(MP_CONSUME, "mpConsume")

  # Shield Stats
  add(SHIELD_DEFENCE_ANGLE, "shieldDefAngle")

  # Skill mastery
  add(SKILL_CRITICAL, "skillCritical")
  add(SKILL_CRITICAL_PROBABILITY, "skillCriticalProbability")

  # Vitality
  add(VITALITY_CONSUME_RATE, "vitalityConsumeRate")

  # Souls
  add(MAX_SOULS, "maxSouls")

  add(REDUCE_EXP_LOST_BY_PVP, "reduceExpLostByPvp")
  add(REDUCE_EXP_LOST_BY_MOB, "reduceExpLostByMob")
  add(REDUCE_EXP_LOST_BY_RAID, "reduceExpLostByRaid")

  add(REDUCE_DEATH_PENALTY_BY_PVP, "reduceDeathPenaltyByPvp")
  add(REDUCE_DEATH_PENALTY_BY_MOB, "reduceDeathPenaltyByMob")
  add(REDUCE_DEATH_PENALTY_BY_RAID, "reduceDeathPenaltyByRaid")

  # Fishing
  add(FISHING_EXPERTISE, "fishingExpertise")
end
