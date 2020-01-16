require "../../../enums/acquire_skill_type"

class Packets::Outgoing::AcquireSkillList < GameServerPacket
  private record SkInfo, id : Int32, next_level : Int32, max_level : Int32,
    sp_cost : Int32, requirements : Int32

  @skills = [] of SkInfo

  initializer skill_type : AcquireSkillType

  def add_skill(id : Int32, next_level : Int32, max_level : Int32, sp_cost : Int32, requirements : Int32)
    @skills << SkInfo.new(id, next_level, max_level, sp_cost, requirements)
  end

  private def write_impl
    return if @skills.empty?

    c 0x90
    d @skill_type.to_i
    d @skills.size
    @skills.each do |skill|
      d skill.id
      d skill.next_level
      d skill.max_level
      d skill.sp_cost
      d skill.requirements
      if @skill_type.subpledge?
        d 0
      end
    end
  end
end
