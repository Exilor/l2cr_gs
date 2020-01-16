module TargetHandler::OwnerPet
  extend self
  extend TargetHandler

  def get_target_list(skill, char, only_first, target) : Array(L2Object)
    if char.is_a?(L2Summon) && char.owner.alive?
      return [char.owner] of L2Object
    end

    EMPTY_TARGET_LIST
  end

  def target_type
    TargetType::OWNER_PET
  end
end
