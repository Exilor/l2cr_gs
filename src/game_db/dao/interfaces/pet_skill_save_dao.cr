module GameDB
  module PetSkillSaveDAO
    macro extended
      include Loggable
    end

    abstract def insert(pet : L2PetInstance, store_effects : Bool)
    abstract def load(pet : L2PetInstance)
  end
end
