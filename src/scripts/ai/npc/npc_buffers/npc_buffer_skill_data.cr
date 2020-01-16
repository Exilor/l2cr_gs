require "../../../../enums/affect_object"

struct NpcBufferSkillData
  getter initial_delay : Int32
  getter delay : Int32
  getter affect_scope : AffectScope
  getter affect_object : AffectObject

  def initialize(set : StatsSet)
    @skill = SkillHolder.new(set.get_i32("id"), set.get_i32("level"))
    @initial_delay = set.get_i32("initialDelay", 0) * 1000
    @delay = set.get_i32("delay") * 1000
    @affect_scope = set.get_enum("affectScope", AffectScope)
    @affect_object = set.get_enum("affectObject", AffectObject)
  end

  def skill : Skill
    @skill.skill
  end
end
