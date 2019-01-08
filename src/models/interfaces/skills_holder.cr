module SkillsHolder
  abstract def skills : Hash(Int32, Skill)
  abstract def add_skill(skill : Skill) : Skill?
  abstract def get_known_skill(skill_id : Int32) : Skill?
  abstract def get_skill_level(skill_id : Int32) : Int32
end
