class OptionsSkillHolder < SkillHolder
  getter skill_type, chance

  def initialize(id, lvl, chance : Float64, skill_type : OptionsSkillType)
    super(id, lvl)

    @chance = chance
    @skill_type = skill_type
  end
end
