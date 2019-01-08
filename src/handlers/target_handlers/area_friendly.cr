module TargetHandler::AreaFriendly
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    player = char.acting_player

    if !check_target(player, target) && skill.cast_range >= 0
      player.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    target = target.not_nil!

    return [target] of L2Object if only_first

    return [player] of L2Object if player.acting_player.in_olympiad_mode?

    target_list = [] of L2Object
    if target
      target_list << target
      max_targets = skill.affect_limit
      target.known_list.each_character(skill.affect_range) do |obj|
        if max_targets > 0 && target_list.size >= max_targets
          break
        end

        if !check_target(player, obj) || obj == char
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

    if target.looks_dead? || target.door? || target.is_a?(L2SiegeFlagInstance) || target.monster?
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

  # private def compare(char1, char2)
  #   (char1.current_hp / char1.max_hp) <=> (char2.current_hp / char2.max_hp)
  # end

  def target_type
    L2TargetType::AREA_FRIENDLY
  end
end
