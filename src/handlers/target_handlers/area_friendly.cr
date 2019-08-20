module TargetHandler::AreaFriendly
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    pc = char.acting_player

    if !check_target(pc, target) && skill.cast_range >= 0
      pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    target = target.not_nil!

    return [target] of L2Object if only_first

    return [pc] of L2Object if pc.in_olympiad_mode?

    target_list = [] of L2Object
    if target
      target_list << target
      max_targets = skill.affect_limit
      target.known_list.each_character(skill.affect_range) do |obj|
        if max_targets > 0 && target_list.size >= max_targets
          break
        end

        if !check_target(pc, obj) || obj == char
          next
        end

        target_list << obj
      end

      target_list.sort_by! do |t|
        t.as(L2Character).current_hp / t.as(L2Character).max_hp
      end
    end

    target_list
  end

  private def check_target(char, target) : Bool
    return false unless target
    return false unless GeoData.can_see_target?(char, target)

    if target.looks_dead? || target.door? || target.is_a?(L2SiegeFlagInstance)
      return false
    end

    if target.monster?
      return false
    end

    return false if target.invisible?

    if target.playable?
      target_player = target.acting_player

      return true if char == target_player

      if target_player.in_observer_mode? || target_player.in_olympiad_mode?
        return false
      end

      return false if char.in_duel_with?(target)
      return true if char.in_party_with?(target)

      if char.in_siege? && !char.on_same_siege_side?(target_player)
        return false
      end

      return false if target.inside_pvp_zone?

      if char.in_clan_with?(target) || char.in_ally_with?(target) || char.in_command_channel_with?(target)
        return true
      end

      if target_player.pvp_flag > 0 || target_player.karma > 0
        return false
      end
    end

    true
  end

  def target_type
    L2TargetType::AREA_FRIENDLY
  end
end
