class CommonSkill < EnumClass
  def initialize(id, level)
    @holder = SkillHolder.new(id, level)
  end

  def id : Int32
    @holder.skill_id
  end

  def level : Int32
    @holder.skill_lvl
  end

  def skill : Skill
    @holder.skill
  end

  def skill? : Skill?
    @holder.skill?
  end

  add(RAID_CURSE, 4215, 1)
  add(RAID_CURSE2, 4515, 1)
  add(SEAL_OF_RULER, 246, 1)
  add(BUILD_HEADQUARTERS, 247, 1)
  add(WYVERN_BREATH, 4289, 1)
  add(STRIDER_SIEGE_ASSAULT, 325, 1)
  add(FIREWORK, 5965, 1)
  add(LARGE_FIREWORK, 2025, 1)
  add(BLESSING_OF_PROTECTION, 5182, 1)
  add(VOID_BURST, 3630, 1)
  add(VOID_FLOW, 3631, 1)
  add(THE_VICTOR_OF_WAR, 5074, 1)
  add(THE_VANQUISHED_OF_WAR, 5075, 1)
  add(SPECIAL_TREE_RECOVERY_BONUS, 2139, 1)
  add(WEAPON_GRADE_PENALTY, 6209, 1)
  add(ARMOR_GRADE_PENALTY, 6213, 1)
  add(CREATE_DWARVEN, 172, 1)
  add(LUCKY, 194, 1)
  add(EXPERTISE, 239, 1)
  add(CRYSTALLIZE, 248, 1)
  add(ONYX_BEAST_TRANSFORMATION, 617, 1)
  add(CREATE_COMMON, 1320, 1)
  add(DIVINE_INSPIRATION, 1405, 1)
  add(SERVITOR_SHARE, 1557, 1)
  add(CARAVANS_SECRET_MEDICINE, 2341, 1)
end
