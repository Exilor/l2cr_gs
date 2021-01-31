module TargetHandler::FrontArea
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    unless target
      char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    if ((target == char || target.looks_dead?) && skill.cast_range >= 0) || !(target.attackable? || target.playable?)
      char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?

    target_list = [] of L2Object

    if skill.cast_range >= 0
      unless skill.offensive_aoe_check(char, target, src_in_arena)
        return EMPTY_TARGET_LIST
      end

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

    char.known_list.each_character do |obj|
      next unless char.playable? || obj.attackable?
      next if obj == origin

      if Util.in_range?(skill.affect_range, origin, obj, true)
        next unless obj.in_front_of?(char)

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
    TargetType::FRONT_AREA
  end
end
