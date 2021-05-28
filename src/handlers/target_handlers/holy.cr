module TargetHandler::Holy
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if target.is_a?(L2ArtefactInstance)
      return [target] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::HOLY
  end
end
