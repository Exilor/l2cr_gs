module TargetHandler::Enemy
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if skill.affect_scope.single?
      unless target
        return EMPTY_TARGET_LIST
      end

      if target.dead?
        char.send_packet(SystemMessageId::INCORRECT_TARGET)
        return EMPTY_TARGET_LIST
      end

      if target.attackable?
        return [target] of L2Object
      end

      unless pc = char.acting_player
        return EMPTY_TARGET_LIST
      end

      unless pc.check_if_pvp(target)
        if (current = pc.current_skill) && current.ctrl?
          char.send_packet(SystemMessageId::INCORRECT_TARGET)
          return EMPTY_TARGET_LIST
        end
      end

      return [target] of L2Object
    end


    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::ENEMY
  end
end
