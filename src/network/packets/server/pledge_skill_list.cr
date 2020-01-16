class Packets::Outgoing::PledgeSkillList < GameServerPacket
  record SubpledgeSkill, sub_type : Int32, skill_id : Int32, skill_lvl : Int32

  @skills : Enumerable(Skill)
  @sub_skills : Array(SubpledgeSkill)

  def initialize(clan : L2Clan)
    @skills = clan.all_skills
    @sub_skills = clan.all_sub_skills
  end

  private def write_impl
    c 0xfe
    h 0x3a

    d @skills.size
    d @sub_skills.size
    @skills.each do |sk|
      d sk.display_id
      d sk.display_level
    end
    @sub_skills.each do |sk|
      d sk.sub_type
      d sk.skill_id
      d sk.skill_lvl
    end
  end
end
