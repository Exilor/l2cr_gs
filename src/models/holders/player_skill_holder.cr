struct PlayerSkillHolder
  include SkillsHolder

  getter skills

  def initialize(pc : L2PcInstance)
    @skills = {} of Int32 => Skill

    pc.skills.each do |id, skill|
      if SkillTreesData.skill_allowed?(pc, skill)
        add_skill(skill)
      end
    end
  end

  def add_skill(skill : Skill)
    @skills[skill.id] = skill
  end

  def get_skill_level(skill_id : Int32) : Int32
    @skills[skill_id]?.try &.level || -1
  end

  def get_known_skill(skill_id : Int32) : Skill?
    @skills[skill_id]?
  end
end
