module TargetHandler::FlagPole
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if target.nil? || !char.player?
      return EMPTY_TARGET_LIST
    end

    [target] of L2Object
  end

  def target_type : TargetType
    TargetType::FLAGPOLE
  end
end
