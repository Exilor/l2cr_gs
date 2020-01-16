class Packets::Incoming::RequestDispel < GameClientPacket
  @l2id = 0
  @skill_id = 0
  @skill_level = 0

  private def read_impl
    @l2id = d
    @skill_id = d
    @skill_level = d
  end

  private def run_impl
    return unless pc = active_char

    return if @skill_id <= 0 || @skill_level <= 0

    return unless skill = SkillData[@skill_id, @skill_level]?

    if skill.irreplaceable_buff? || skill.stay_after_death? || skill.debuff?
      return
    end

    if skill.abnormal_type.transform?
      return
    end

    if skill.dance? && !Config.dance_cancel_buff
      return
    end

    if pc.l2id == @l2id
      pc.stop_skill_effects(true, @skill_id)
    elsif (smn = pc.summon) && smn.l2id == @l2id
      smn.stop_skill_effects(true, @skill_id)
    end
  end
end
