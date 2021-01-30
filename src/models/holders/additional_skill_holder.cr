require "./skill_holder"

class AdditionalSkillHolder < SkillHolder

  getter min_level

  def initialize(skill_id : Int32, skill_level : Int32, min_level : Int32)
    super(skill_id, skill_level)
    @min_level = min_level
  end
end
