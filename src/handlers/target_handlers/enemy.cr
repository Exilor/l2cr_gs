module TargetHandler::Enemy
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    case skill.affect_scope
    when AffectScope::SINGLE
      unless target
        return EMPTY_TARGET_LIST
      end

      pc = char.acting_player

      if target.dead? || (!target.attackable? && pc && !pc.check_if_pvp(target) && !pc.current_skill.not_nil!.ctrl?)
        char.send_packet(SystemMessageId::INCORRECT_TARGET)
        return EMPTY_TARGET_LIST
      end

      return [target] of L2Object
    else
      # automatically added
    end


    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::ENEMY
  end
end