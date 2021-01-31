module TargetHandler::Target
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    return EMPTY_TARGET_LIST unless target

    if (pc = char.acting_player) && (current = pc.current_skill)
      if !current.ctrl? && target.auto_attackable?(pc)
        char.send_packet(SystemMessageId::INCORRECT_TARGET)
        return EMPTY_TARGET_LIST
      end
    end

    skill.affect_scope.affect_targets(char, target, skill).to_a
  end

  def target_type : TargetType
    TargetType::TARGET
  end
end
