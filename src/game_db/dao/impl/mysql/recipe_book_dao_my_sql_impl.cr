module GameDB
  module RecipeBookDAOMySQLImpl
    extend self
    extend RecipeBookDAO

    private INSERT = "INSERT INTO character_recipebook (charId, id, classIndex, type) values(?,?,?,?)"
    private DELETE = "DELETE FROM character_recipebook WHERE charId=? AND id=? AND classIndex=?"
    private SELECT_COMMON = "SELECT id, type, classIndex FROM character_recipebook WHERE charId=?"
    private SELECT = "SELECT id FROM character_recipebook WHERE charId=? AND classIndex=? AND type = 1"

    def insert(pc : L2PcInstance, recipe_id : Int32, dwarf : Bool)
      GameDB.exec(
        INSERT,
        pc.l2id,
        recipe_id,
        dwarf ? pc.class_index : 0,
        dwarf ? 1 : 0
      )
    rescue e
      error e
    end

    def delete(pc : L2PcInstance, recipe_id : Int32, dwarf : Bool)
      GameDB.exec(
        DELETE,
        pc.l2id,
        recipe_id,
        dwarf ? pc.class_index : 0
      )
    rescue e
      error e
    end

    def load(pc : L2PcInstance, common : Bool)
      pc.@dwarven_recipe_book.try &.clear # L2J wonders why clear only dwarven recipes

      if common
        GameDB.each(SELECT_COMMON, pc.l2id) do |rs|
          recipe = RecipeData.get_recipe_list(rs.get_i32("id"))
          if rs.get_i32("type") == 1
            if rs.get_i32("classIndex") == pc.class_index
              pc.register_dwarven_recipe_list(recipe, false)
            end
          else
            pc.register_common_recipe_list(recipe, false)
          end
        end
      else
        GameDB.each(SELECT, pc.l2id, pc.class_index) do |rs|
          recipe = RecipeData.get_recipe_list(rs.get_i32("id"))
          pc.register_dwarven_recipe_list(recipe, false)
        end
      end
    rescue e
      error e
    end
  end
end
