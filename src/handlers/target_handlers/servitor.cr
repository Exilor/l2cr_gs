module TargetHandler::Servitor
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if servitor = char.summon.as?(L2ServitorInstance)
      return [servitor] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::SERVITOR
  end
end
