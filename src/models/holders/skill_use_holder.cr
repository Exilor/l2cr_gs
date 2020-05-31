require "./skill_holder"

class SkillUseHolder < SkillHolder
  getter? ctrl, shift

  def initialize(skill : Skill, ctrl : Bool, shift : Bool)
    super(skill)

    @ctrl = ctrl
    @shift = shift
  end
end
