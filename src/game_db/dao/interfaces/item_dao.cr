module GameDB
  module ItemDAO
    include Loggable

    abstract def load_pet_inventory(pc : L2PcInstance)
  end
end
