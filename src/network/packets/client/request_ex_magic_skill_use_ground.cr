class Packets::Incoming::RequestExMagicSkillUseGround < GameClientPacket
  @x = 0
  @y = 0
  @z = 0
  @skill_id = 0
  @ctrl = false
  @shift = false

  private def read_impl
    @x, @y, @z = d, d, d
    @skill_id = d
    @ctrl = d != 0
    @shift = c != 0
  end

  private def run_impl
    return unless pc = active_char

    level = pc.get_skill_level(@skill_id)
    if level <= 0
      return action_failed
    end

    if skill = SkillData[@skill_id, level]?
      pc.current_skill_world_position = Location.new(@x, @y, @z)
      pc.heading = Util.calculate_heading_from(pc.x, pc.y, @x, @y)
      Broadcast.to_known_players(pc, ValidateLocation.new(pc))
      pc.use_magic(skill, @ctrl, @shift)
    else
      action_failed
      warn "No skill found with ID #{@skill_id} and level #{level}."
    end
  end
end
