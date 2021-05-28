module TargetHandler::AreaCorpseMob
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if target.nil? || (!target.attackable? || target.alive?)
      if char.acting_player
        char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      end

      return EMPTY_TARGET_LIST
    end

    target_list = [target] of L2Object

    return target_list if only_first

    src_in_arena = char.inside_pvp_zone? && !char.inside_siege_zone?

    char.known_list.known_characters do |obj|
      if !(obj.attackable? || obj.playable?) || !Util.in_range?(skill.affect_range, target, obj, true)
        next
      end

      unless skill.offensive_aoe_check(char, obj, src_in_arena)
        next
      end

      target_list << obj
    end

    target_list
  end

  def target_type : TargetType
    TargetType::AREA_CORPSE_MOB
  end
end
