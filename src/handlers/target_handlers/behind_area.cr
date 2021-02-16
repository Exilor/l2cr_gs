module TargetHandler::BehindArea
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    unless target
      char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    if ((target == char || target.looks_dead?) && skill.cast_range >= 0) ||
       !(target.attackable? || target.playable?)
      char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?

    target_list = nil

    if skill.cast_range >= 0
      unless skill.offensive_aoe_check(char, target, src_in_arena)
        return EMPTY_TARGET_LIST
      end

      target_list ||= [] of L2Object

      if only_first
        target_list << target
        return target_list
      end

      origin = target
      target_list << origin
    else
      origin = char
    end

    max_targets = skill.affect_limit

    char.known_list.known_characters do |obj|
      next unless char.playable? || obj.attackable?
      next if obj == origin

      if Util.in_range?(skill.affect_range, origin, obj, true)
        next unless obj.behind?(char)

        unless skill.offensive_aoe_check(char, obj, src_in_arena)
          next
        end

        if max_targets > 0 && target_list && target_list.size >= max_targets
          break
        end

        target_list ||= [] of L2Object
        target_list << obj
      end
    end

    target_list || EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::BEHIND_AREA
  end
end
