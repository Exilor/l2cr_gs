class Packets::Outgoing::RecipeBookItemList < GameServerPacket
  @recipes = Slice(L2RecipeList).empty

  initializer dwarven_craft : Bool, max_mp : Int32

  def add_recipes(recipes : Slice(L2RecipeList))
    @recipes = recipes
  end

  private def write_impl
    c 0xdc

    d @dwarven_craft ? 0 : 1
    d @max_mp

    d @recipes.size
    @recipes.each_with_index(1) do |rp, i|
      d rp.id
      d i
    end
  end
end
