abstract class AbstractResidence < ListenersContainer
  include Packets::Outgoing
  # include Namable

  @residential_skills = [] of SkillHolder
  getter residence_id : Int32
  property name : String = ""
  # L2J: _zone (Castle has its own @zone but of another type)
  property residence_zone : L2ResidenceZone?

  def_equals @residential_skills

  def initialize(@residence_id : Int32)
    init_residential_skills
  end

  abstract def load
  abstract def init_residence_zone

  private def init_residential_skills
    SkillTreesData.get_available_residential_skills(residence_id).each do |s|
      @residential_skills << SkillHolder.new(s.skill_id, s.skill_level)
    end
  end

  # def residence_zone
  #   @zone.as?(L2ResidenceZone)
  # end

  # def residence_zone=(@zone : L2ResidenceZone)
  # end

  def give_residential_skills(pc)
    @residential_skills.each do |sh|
      pc.add_skill(sh.skill, false)
    end
  end

  def remove_residential_skills(pc)
    @residential_skills.each do |sh|
      pc.remove_skill(sh.skill, false)
    end
  end

  def to_log(io : IO)
    super
    io << '(' << name << ')'
  end
end
