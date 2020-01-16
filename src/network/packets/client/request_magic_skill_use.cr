class Packets::Incoming::RequestMagicSkillUse < GameClientPacket
  @id = 0
  @ctrl = false
  @shift = false

  private def read_impl
    @id = d
    @ctrl = d != 0
    @shift = c != 0
  end

  private def run_impl
    return unless pc = active_char

    if pc.dead?
      action_failed
      return
    end

    if pc.fake_death?
      pc.send_packet(SystemMessageId::CANT_MOVE_SITTING)
      action_failed
      return
    end

    unless skill = pc.get_known_skill(@id)
      unless skill = pc.get_custom_skill(@id)
        unless skill = pc.get_transform_skill(@id)
          warn { "Skill with ID #{@id} not known by player #{pc.name}." }
          action_failed
          return
        end
      end
    end
    # L2J also checks if pc.playable? which is useless because pc can only be a
    # L2PcInstance and all L2Playable return true on #playable?.
    if pc.in_airship?
      pc.send_packet(SystemMessageId::ACTION_PROHIBITED_WHILE_MOUNTED_OR_ON_AN_AIRSHIP)
      action_failed
      return
    end

    if (pc.transformed? || pc.in_stance?) && !pc.has_transform_skill?(@id)
      action_failed
      return
    end

    unless Config.alt_game_karma_player_can_teleport
      if pc.karma > 0 && skill.has_effect_type?(EffectType::TELEPORT)
        return
      end
    end

    if skill.toggle? && pc.mounted?
      return
    end

    if skill.continuous? && !skill.debuff? && skill.target_type.self? && (!pc.in_airship? && !pc.in_boat?) # custom: L2J uses || instead of the last &&
      pc.set_intention(AI::MOVE_TO, pc.location)
    end
    # custom: allows deactivating a toggle skill while sitting
    if skill.toggle? && pc.affected_by_skill?(skill.id)
      pc.stop_skill_effects(true, skill.id)
    else
      pc.use_magic(skill, @ctrl, @shift)
    end
  end
end
