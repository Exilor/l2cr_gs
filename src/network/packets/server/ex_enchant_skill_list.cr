class Packets::Outgoing::ExEnchantSkillList < GameServerPacket
  enum EnchantSkillType : UInt8
    NORMAL, SAFE, UNTRAIN, CHANGE_ROUTE
  end

  private record Skill, id : Int32, next_level : Int32

  @skills = [] of Skill

  initializer type: EnchantSkillType

  def write_impl
    c 0xfe
    h 0x29

    d @type.to_i
    d @skills.size
    @skills.each do |sk|
      d sk.id
      d sk.next_level
    end
  end
end
