module TargetHandler::Unlockable
  extend self
  extend TargetHandler

  TARGET_TYPE = TargetType::UNLOCKABLE

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if target.is_a?(L2DoorInstance) || target.is_a?(L2ChestInstance)
      return [target] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::UNLOCKABLE
  end
end
