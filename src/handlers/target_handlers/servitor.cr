module TargetHandler::Servitor
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    char.has_servitor? ? [char.summon!] of L2Object : EMPTY_TARGET_LIST
  end

  def target_type
    L2TargetType::SERVITOR
  end
end
