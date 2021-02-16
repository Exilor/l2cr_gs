module TargetHandler::Area
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if !target || ((target == char || target.looks_dead?) && skill.cast_range >= 0) || (!(target.is_a?(L2Attackable) || target.is_a?(L2Playable)))
      if char.acting_player
        char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      end
      return EMPTY_TARGET_LIST
    end

    target = target.not_nil!

    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?
    if skill.cast_range >= 0
      unless skill.offensive_aoe_check(char, target, src_in_arena)
        return EMPTY_TARGET_LIST
      end

      if only_first
        return [target] of L2Object
      end

      origin = target
      target_list = [origin] of L2Object
    else
      origin = char
    end

    target_list ||= [] of L2Object

    max_targets = skill.affect_limit

    char.known_list.known_characters do |obj|
      next unless obj.attackable? || obj.playable?
      next if obj == origin

      if Util.in_range?(skill.affect_range, origin, obj, true)
        unless skill.offensive_aoe_check(char, obj, src_in_arena)
          next
        end

        break if max_targets > 0 && target_list.size >= max_targets

        target_list << obj
      end
    end

    target_list
  end

  def target_type : TargetType
    TargetType::AREA
  end
end
