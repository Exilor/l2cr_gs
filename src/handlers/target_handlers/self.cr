module TargetHandler::Self
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    [char] of L2Object
  end

  def target_type
    TargetType::SELF
  end
end
