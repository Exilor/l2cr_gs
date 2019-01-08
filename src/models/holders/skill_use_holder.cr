require "./skill_holder"

class SkillUseHolder < SkillHolder
  getter? ctrl, shift

  def initialize(skill : Skill, @ctrl : Bool, @shift : Bool)
    super(skill)
  end
end
