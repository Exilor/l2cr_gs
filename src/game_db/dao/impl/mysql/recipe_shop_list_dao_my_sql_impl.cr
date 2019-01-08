module GameDB
  module RecipeShopListDAOMySQLImpl
    extend self
    extend RecipeShopListDAO

    private DELETE = "DELETE FROM character_recipeshoplist WHERE charId=?"
    private INSERT = "REPLACE INTO character_recipeshoplist (`charId`, `recipeId`, `price`, `index`) VALUES (?, ?, ?, ?)"
    private SELECT = "SELECT * FROM character_recipeshoplist WHERE charId=? ORDER BY `index`"

    def load(pc : L2PcInstance)
      pc.manufacture_items.clear

      GameDB.each(SELECT, pc.l2id) do |rs|
        recipe_id = rs.get_i32("recipeId")
        price = rs.get_i64("price")

        item = L2ManufactureItem.new(recipe_id, price)
        pc.manufacture_items[recipe_id] = item
      end
    rescue e
      error e
    end

    def delete(pc : L2PcInstance)
      GameDB.exec(DELETE, pc.l2id)
    rescue e
      error e
    end

    def insert(pc : L2PcInstance)
      pc.manufacture_items.local_each_value.with_index do |item, i|
        GameDB.exec(
          INSERT,
          pc.l2id,
          item.recipe_id,
          item.cost,
          i + 1
        )
      end
    rescue e
      error e
    end
  end
end
