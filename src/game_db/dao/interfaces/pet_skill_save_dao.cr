module GameDB
  module PetSkillSaveDAO
    include Loggable

    abstract def insert(pet : L2PetInstance, store_effects : Bool)
    abstract def load(pet : L2PetInstance)
  end
end
