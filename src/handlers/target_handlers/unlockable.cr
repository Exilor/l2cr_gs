module TargetHandler::Unlockable
  extend self
  extend TargetHandler

  TARGET_TYPE = TargetType::UNLOCKABLE

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if target.is_a?(L2DoorInstance) || target.is_a?(L2ChestInstance)
      return [target] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::UNLOCKABLE
  end
end
