require "./skill_holder"

struct SkillUseHolder
  getter skill
  getter? ctrl, shift

  initializer skill : Skill, ctrl : Bool, shift : Bool

  def skill_id : Int32
    @skill.id
  end
end
