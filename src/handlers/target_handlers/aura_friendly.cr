module TargetHandler::AuraFriendly
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    player = char.acting_player.not_nil!

    if target.nil? || (!check_target(player, target) && skill.cast_range >= 0)
      player.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    return [target] of L2Object if only_first

    return [player] of L2Object if player.acting_player.try &.in_olympiad_mode?

    target_list = nil
    if target
      target_list ||= [] of L2Object
      target_list << target
      max_targets = skill.affect_limit
      target.known_list.get_known_characters_in_radius(skill.affect_range) do |obj|
        if max_targets > 0 && target_list.size >= max_targets
          break
        end

        if !check_target(player, obj) || obj == char
          next
        end

        target_list << obj
      end
    end

    target_list || EMPTY_TARGET_LIST
  end

  private def check_target(char, target)
    return false unless GeoData.can_see_target?(char, target)

    if target.looks_dead? || target.door? || target.is_a?(L2SiegeFlagInstance) || target.monster?
      return false
    end

    return false if target.invisible?

    if target.playable?
      return false unless target_player = target.acting_player

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

  def target_type : TargetType
    TargetType::AURA_FRIENDLY
  end
end
