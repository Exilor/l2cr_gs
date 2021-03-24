module GameDB
  module RecipeBookDAO
    macro extended
      include Loggable
    end

    abstract def insert(pc : L2PcInstance, recipe_id : Int32, dwarf : Bool)
    abstract def load(pc : L2PcInstance, common : Bool)
    abstract def delete(pc : L2PcInstance, recipe_id : Int32, dwarf : Bool)
  end
end
