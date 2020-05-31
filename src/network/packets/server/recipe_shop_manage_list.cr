class Packets::Outgoing::RecipeShopManageList < GameServerPacket
  @recipes : Enumerable(L2RecipeList)

  def initialize(@seller : L2PcInstance, @dwarven : Bool)
    if dwarven && seller.has_dwarven_craft?
      @recipes = seller.dwarven_recipe_book
    else
      @recipes = seller.common_recipe_book
    end

    if seller.has_manufacture_shop?
      items = seller.manufacture_items
      items.each_value do |item|
        if item.dwarven? != dwarven || !seller.has_recipe_list?(item.recipe_id)
          items.delete(item.recipe_id) # check what's the key
        end
      end
    end
  end

  private def write_impl
    c 0xde

    d @seller.l2id
    d @seller.adena
    d @dwarven ? 0 : 1

    recipes = @recipes

    if recipes.nil?
      d 0
    else
      d recipes.size
      recipes.each_with_index do |recipe, i|
        d recipe.id
        d i &+ 1
      end
    end

    if !@seller.has_manufacture_shop?
      d 0
    else
      d @seller.manufacture_items.size
      @seller.manufacture_items.each_value do |item|
        d item.recipe_id
        d 0
        q item.cost
      end
    end
  end
end
