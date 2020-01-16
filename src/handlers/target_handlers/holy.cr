module TargetHandler::Holy
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if target.is_a?(L2ArtefactInstance)
      return [target] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::HOLY
  end
end
