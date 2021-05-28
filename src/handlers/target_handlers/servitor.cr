module TargetHandler::Servitor
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if servitor = char.summon.as?(L2ServitorInstance)
      return [servitor] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::SERVITOR
  end
end
