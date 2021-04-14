module TargetHandler::FlagPole
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if target.nil? || !char.player?
      return EMPTY_TARGET_LIST
    end

    [target] of L2Object
  end

  def target_type : TargetType
    TargetType::FLAGPOLE
  end
end
