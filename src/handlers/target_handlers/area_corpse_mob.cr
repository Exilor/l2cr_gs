module TargetHandler::AreaCorpseMob
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if target.nil? || (!target.attackable? || target.alive?)
      if char.acting_player?
        char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      end

      return EMPTY_TARGET_LIST
    end

    target_list = [target] of L2Object

    return target_list if only_first

    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?

    char.known_list.each_character do |obj|
      if !(obj.attackable? || obj.playable?) || !Util.in_range?(skill.affect_range, target, obj, true)
        next
      end

      if !Skill.check_for_area_offensive_skills(char, obj, skill, src_in_arena)
        next
      end

      target_list << obj
    end

    target_list
  end

  def target_type
    L2TargetType::AREA_CORPSE_MOB
  end
end
