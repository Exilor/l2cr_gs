class Packets::Outgoing::SkillList < GameServerPacket
  private record SkillInfo, id : Int32, level : Int32, passive : Bool,
    disabled : Bool, enchantable : Bool

  @skills = [] of SkillInfo

  def add_skill(id : Int32, level : Int32, passive : Bool, disabled : Bool, enchantable : Bool)
    @skills << SkillInfo.new(id, level, passive, disabled, enchantable)
  end

  private def write_impl
    c 0x5f

    d @skills.size
    @skills.each do |skill|
      d skill.passive ? 1 : 0
      d skill.level
      d skill.id
      c skill.disabled ? 1 : 0
      c skill.enchantable ? 1 : 0
    end
  end
end
