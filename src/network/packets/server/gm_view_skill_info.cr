class Packets::Outgoing::GMViewSkillInfo < GameServerPacket
  @skills : Enumerable(Skill)

  def initialize(@pc : L2PcInstance)
    @skills = @pc.all_skills
  end

  private def write_impl
    c 0x97

    s @pc.name
    d @skills.size
    clan = @pc.clan
    disabled = clan && clan.reputation_score < 0
    @skills.each do |skill|
      d skill.passive? ? 1 : 0
      d skill.display_level
      d skill.display_id
      c disabled && skill.clan_skill? ? 1 : 0
      c SkillData.enchantable?(skill.display_id) ? 1 : 0
    end
  end
end
