module TargetHandler::AreaSummon
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    target = char.summon
    if target.nil? || (!target.servitor? || target.dead?)
      return EMPTY_TARGET_LIST
    end

    return [target] of L2Object if only_first

    target_list = nil
    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?
    max_targets = skill.affect_limit
    char.known_list.each_character do |obj|
      next if obj == target || obj == char

      next unless Util.in_range?(skill.affect_range, target, obj, true)

      next if !(obj.attackable? || obj.playable?)

      if !Skill.check_for_area_offensive_skills(char, obj, skill, src_in_arena)
        next
      end

      if max_targets > 0 && target_list && target_list.size >= max_targets
        break
      end
      target_list ||= [] of L2Object
      target_list << obj
    end

    target_list || EMPTY_TARGET_LIST
  end

  def target_type
    L2TargetType::AREA_SUMMON
  end
end
