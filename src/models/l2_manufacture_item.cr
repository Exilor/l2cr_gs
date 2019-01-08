struct L2ManufactureItem
  getter recipe_id, cost
  getter? dwarven : Bool

  def initialize(@recipe_id : Int32, @cost : Int64)
    @dwarven = RecipeData.get_recipe_list(recipe_id).dwarven_recipe?
  end
end
