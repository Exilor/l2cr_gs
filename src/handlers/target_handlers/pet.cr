module TargetHandler::Pet
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if pet = char.summon.as?(L2PetInstance)
      return [pet] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type : TargetType
    TargetType::PET
  end
end
