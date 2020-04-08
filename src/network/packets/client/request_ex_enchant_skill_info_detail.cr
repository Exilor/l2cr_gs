class Packets::Incoming::RequestExEnchantSkillInfoDetail < GameClientPacket
  @type = 0
  @skill_id = 0
  @skill_lvl = 0

  private def read_impl
    @type = d
    @skill_id = d
    @skill_lvl = d
  end

  private def run_impl
    return if @skill_id <= 0 || @skill_lvl <= 0

    return unless pc = active_char

    req_skill_lvl = -2

    case @type
    when 0..1
      req_skill_lvl = @skill_lvl - 1 # enchant
    when 2
      req_skill_lvl = @skill_lvl + 1 # untrain
    when 3
      req_skill_lvl = @skill_lvl # change route
    else
      # automatically added
    end


    player_skill_lvl = pc.get_skill_level(@skill_id)

    if player_skill_lvl == -1
      warn { "#{pc} doesn't know skill with ID #{@skill_id}." }
      return
    end

    if req_skill_lvl % 100 == 0
      esl = EnchantSkillGroupsData.get_skill_enchantment_by_skill_id(@skill_id)
      if esl
        if player_skill_lvl != esl.base_level
          warn { "#{pc}'s skill level of #{player_skill_lvl} doesn't match the base level of #{esl}." }
          debug esl.inspect
          return
        end
      else
        warn { "No enchant data found for skill with ID #{@skill_id}." }
        return
      end
    elsif player_skill_lvl != req_skill_lvl
      if @type == 3 && player_skill_lvl % 100 != @skill_lvl % 100
        return
      end
    end

    esd = ExEnchantSkillInfoDetail.new(@type, @skill_id, @skill_lvl, pc)
    send_packet(esd)
  end
end