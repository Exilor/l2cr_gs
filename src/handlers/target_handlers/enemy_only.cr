module TargetHandler::EnemyOnly
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    unless skill.affect_scope.single?
      return EMPTY_TARGET_LIST
    end

    unless target
      return EMPTY_TARGET_LIST
    end

    if target == char
      char.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    if target.dead?
      char.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    if target.npc?
      if target.attackable?
        return [target] of L2Object
      end
      char.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    unless pc = char.acting_player
      return EMPTY_TARGET_LIST
    end

    # In Olympiad, different sides.
    if pc.in_olympiad_mode?
      target_pc = target.acting_player
      if target_pc && pc.olympiad_side != target_pc.olympiad_side
        return [target] of L2Object
      end
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    # In Duel, different sides.
    if pc.in_duel_with?(target)
      target_pc = target.acting_player
      duel = DuelManager.get_duel(pc.duel_id).not_nil!
      team_a = duel.team_a
      team_b = duel.team_b
      if team_a.includes?(pc) && team_b.includes?(target_pc)
        return [target] of L2Object
      end
      if team_b.includes?(pc) && team_a.includes?(target_pc)
        return [target] of L2Object
      end
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    # Not in same party.
    if pc.in_party_with?(target)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    # In PVP Zone.
    if pc.inside_pvp_zone?
      return [target] of L2Object
    end

    # Not in same clan.
    if pc.in_clan_with?(target)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    # L2J TODO: Validate.
    # Not in same alliance.
    if pc.in_ally_with?(target)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    # L2J TODO: Validate.
    # Not in same command channel.
    if pc.in_command_channel_with?(target)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    # Not on same Siege Side.
    if pc.on_same_siege_side_with?(target)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    # At Clan War.
    if pc.at_war_with?(target)
      return [target] of L2Object
    end

    # Cannot PvP.
    unless pc.check_if_pvp(target)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    [target] of L2Object
  end

  def target_type : TargetType
    TargetType::ENEMY_ONLY
  end
end
