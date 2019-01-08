struct L2RecipeList
  getter recipes = [] of L2RecipeInstance
  getter id : Int32
  getter level : Int32
  getter recipe_id : Int32
  getter recipe_name : String
  getter success_rate : Int32
  getter item_id : Int32
  getter count : Int32
  getter stat_use = [] of L2RecipeStatInstance
  getter alt_stat_change = [] of L2RecipeStatInstance
  getter rare_item_id = 0
  getter rare_count = 0
  getter rarity = 0
  getter? dwarven_recipe : Bool

  def initialize(set : StatsSet, has_rare : Bool)
    @id = set.get_i32("id")
    @level = set.get_i32("craftLevel")
    @recipe_id = set.get_i32("recipeId")
    @recipe_name = set.get_string("recipeName")
    @success_rate = set.get_i32("successRate")
    @item_id = set.get_i32("itemId")
    @count = set.get_i32("count")

    if has_rare
      @rare_item_id = set.get_i32("rareItemId")
      @rare_count = set.get_i32("rareCount")
      @rarity = set.get_i32("rarity")
    end

    @dwarven_recipe = set.get_bool("isDwarvenRecipe")
  end

  def add_recipe(recipe : L2RecipeInstance)
    @recipes << recipe
  end

  def add_stat_use(stat_use : L2RecipeStatInstance)
    @stat_use << stat_use
  end

  def add_alt_stat_change(stat_change : L2RecipeStatInstance)
    @alt_stat_change << stat_change
  end
end
