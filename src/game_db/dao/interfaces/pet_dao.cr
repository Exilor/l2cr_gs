module GameDB
  module PetDAO
    macro extended
      include Loggable
    end

    abstract def update_food(pc : L2PcInstance, pet_id : Int32)
    abstract def delete(pet : L2PetInstance)
    abstract def load(control : L2ItemInstance, template : L2NpcTemplate, owner : L2PcInstance) : L2PetInstance?
    abstract def insert(pet : L2PetInstance)
    abstract def update(pet : L2PetInstance)
  end
end
