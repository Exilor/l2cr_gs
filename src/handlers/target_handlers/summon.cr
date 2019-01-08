module TargetHandler::Summon
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    char.has_summon? ? [char.summon!] of L2Object : EMPTY_TARGET_LIST
  end

  def target_type
    L2TargetType::SUMMON
  end
end
