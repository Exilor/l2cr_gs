module TargetHandler::Self
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    [char] of L2Object
  end

  def target_type : TargetType
    TargetType::SELF
  end
end
