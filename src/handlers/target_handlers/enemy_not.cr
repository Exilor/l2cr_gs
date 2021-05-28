module TargetHandler::EnemyNot
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    return EMPTY_TARGET_LIST unless target

    if target.dead? || target.auto_attackable?(char)
      char.send_packet(SystemMessageId::INCORRECT_TARGET)
      return EMPTY_TARGET_LIST
    end

    skill.affect_scope.get_affected_targets(char, target, skill)
  end

  def target_type : TargetType
    TargetType::ENEMY_NOT
  end
end
