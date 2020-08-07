struct EffectDurationHolder
  getter skill_id : Int32, skill_lvl : Int32, duration : Int32

  def initialize(skill : Skill, duration : Int32)
    @skill_id  = skill.display_id
    @skill_lvl = skill.display_level
    @duration  = duration
  end
end
