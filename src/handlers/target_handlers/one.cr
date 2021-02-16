module TargetHandler::One
  extend TargetHandler
  extend self

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if target.nil? || (target.dead? || (target == char && skill.bad?))
      char.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return EMPTY_TARGET_LIST
    end

    [target] of L2Object
  end

  def target_type : TargetType
    TargetType::ONE
  end
end
