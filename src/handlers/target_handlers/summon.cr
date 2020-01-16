module TargetHandler::Summon
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if smn = char.summon
      return [smn] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::SUMMON
  end
end
