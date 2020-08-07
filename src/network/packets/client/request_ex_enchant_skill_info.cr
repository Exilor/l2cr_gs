class Packets::Incoming::RequestExEnchantSkillInfo < GameClientPacket
  @skill_id = 0
  @skill_lvl = 0

  private def read_impl
    @skill_id = d
    @skill_lvl = d
  end

  private def run_impl
    return if @skill_id <= 0 || @skill_lvl <= 0
    return unless pc = active_char
    return if pc.level < 76

    unless skill = SkillData[@skill_id, @skill_lvl]?
      warn { "Skill with id #{@skill_id} and level #{@skill_lvl} not found." }
      return
    end

    return if skill.id != @skill_id

    unless EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(@skill_id)
      warn { "No enchant info found for skill with id #{@skill_id}." }
      return
    end

    player_skill_lvl = pc.get_skill_level(@skill_id)

    if player_skill_lvl == -1 || player_skill_lvl != @skill_lvl
      warn { "Player doesn't have skill with id #{@skill_id} and level #{@skill_lvl}." }
      return
    end

    send_packet(ExEnchantSkillInfo.new(@skill_id, @skill_lvl))
  end
end
