class Packets::Incoming::RequestAcquireSkillInfo < GameClientPacket
  @id = 0
  @level = 0
  @skill_type = AcquireSkillType::CLASS

  private def read_impl
    @id, @level = d, d
    @skill_type = AcquireSkillType[d]
  end

  private def run_impl
    if @id <= 0 || @level <= 0
      warn { "Invalid id or level. Id: #{@id}, level: #{@level}." }
      return
    end

    return unless pc = active_char

    trainer = pc.last_folk_npc

    unless trainer.is_a?(L2NpcInstance)
      warn { "#{pc}'s @last_folk_npc (#{trainer}) is not a trainer." }
      return
    end

    if !trainer.can_interact?(pc) && !pc.gm?
      debug { "#{trainer} can't interact with #{pc}." }
      return
    end

    unless SkillData[@id, @level]?
      warn { "Skill with id #{@id} and level #{@level} doesn't exist." }
      return
    end

    prev_skill_level = pc.get_skill_level(@id)
    if prev_skill_level > 0 && !(@skill_type.transfer? || @skill_type.subpledge?)
      if prev_skill_level == @level
        warn { pc.name + " requested info for a skill he already knows." }
        return
      elsif prev_skill_level != @level &- 1
        warn { "#{pc} doesn't know the previous level of skill with id #{@id} and level #{@level}." }
        return
      end
    end

    unless s = SkillTreesData.get_skill_learn(@skill_type, @id, @level, pc)
      debug { "No skill learn data for skill with id #{@id} and level #{@level}." }
      return
    end

    if @skill_type.transform? || @skill_type.fishing? || @skill_type.subclass? || @skill_type.collect? || @skill_type.transfer?
      send_packet(AcquireSkillInfo.new(@skill_type, s))
    elsif @skill_type.class?
      if trainer.template.can_teach?(pc.learning_class)
        custom_sp = s.get_calculated_level_up_sp(pc.class_id, pc.learning_class)
        send_packet(AcquireSkillInfo.new(@skill_type, s, custom_sp))
      end
    elsif @skill_type.pledge?
      unless pc.clan_leader?
        return
      end

      send_packet(AcquireSkillInfo.new(@skill_type, s))
    elsif @skill_type.subpledge?
      if !pc.clan_leader? || !pc.has_clan_privilege?(ClanPrivilege::CL_TROOPS_FAME)
        send_packet(AcquireSkillInfo.new(@skill_type, s))
      end
    end
  end
end
