class CommonSkill
  private def initialize(id, level)
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

  RAID_CURSE = new(4215, 1)
  RAID_CURSE2 = new(4515, 1)
  SEAL_OF_RULER = new(246, 1)
  BUILD_HEADQUARTERS = new(247, 1)
  WYVERN_BREATH = new(4289, 1)
  STRIDER_SIEGE_ASSAULT = new(325, 1)
  FIREWORK = new(5965, 1)
  LARGE_FIREWORK = new(2025, 1)
  BLESSING_OF_PROTECTION = new(5182, 1)
  VOID_BURST = new(3630, 1)
  VOID_FLOW = new(3631, 1)
  THE_VICTOR_OF_WAR = new(5074, 1)
  THE_VANQUISHED_OF_WAR = new(5075, 1)
  SPECIAL_TREE_RECOVERY_BONUS = new(2139, 1)
  WEAPON_GRADE_PENALTY = new(6209, 1)
  ARMOR_GRADE_PENALTY = new(6213, 1)
  CREATE_DWARVEN = new(172, 1)
  LUCKY = new(194, 1)
  EXPERTISE = new(239, 1)
  CRYSTALLIZE = new(248, 1)
  ONYX_BEAST_TRANSFORMATION = new(617, 1)
  CREATE_COMMON = new(1320, 1)
  DIVINE_INSPIRATION = new(1405, 1)
  SERVITOR_SHARE = new(1557, 1)
  CARAVANS_SECRET_MEDICINE = new(2341, 1)
end
