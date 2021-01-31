module TargetHandler::EnemyNot
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    return EMPTY_TARGET_LIST unless target

    if target.dead?
      char.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    if target.auto_attackable?(char)
      char.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    skill.affect_scope.affect_targets(char, target, skill).to_a
  end

  def target_type : TargetType
    TargetType::ENEMY_NOT
  end
end
