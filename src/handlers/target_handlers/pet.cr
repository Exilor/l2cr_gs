module TargetHandler::Pet
  extend self
  extend TargetHandler

  def get_target_list(skill : Skill, char : L2Character, only_first : Bool, target : L2Character?) : Array(L2Object)
    if pet = char.summon.as?(L2PetInstance)
      return [pet] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::PET
  end
end
