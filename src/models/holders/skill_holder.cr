class SkillHolder
  getter_initializer skill_id : Int32, skill_lvl : Int32

  def initialize(skill_id : Int32)
    @skill_id = skill_id
    @skill_lvl = 1
  end

  def initialize(skill : Skill)
    @skill_id, @skill_lvl = skill.id, skill.level
  end

  def skill : Skill
    SkillData[@skill_id, Math.max(@skill_lvl, 1)]
  end

  def skill? : Skill?
    SkillData[@skill_id, Math.max(@skill_lvl, 1)]?
  end
end
