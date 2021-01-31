module TargetHandler::FlagPole
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    unless char.player?
      return EMPTY_TARGET_LIST
    end

    [target.not_nil!] of L2Object
  end

  def target_type : TargetType
    TargetType::FLAGPOLE
  end
end
