module GameDB
  module ItemDAO
    macro extended
      include Loggable
    end

    abstract def load_pet_inventory(pc : L2PcInstance)
  end
end
