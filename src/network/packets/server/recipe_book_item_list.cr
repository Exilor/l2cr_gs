class Packets::Outgoing::RecipeBookItemList < GameServerPacket
  @recipes : Enumerable(L2RecipeList)?

  initializer dwarven_craft : Bool, max_mp : Int32

  def add_recipes(@recipes : Enumerable(L2RecipeList))
  end

  private def write_impl
    c 0xdc

    d @dwarven_craft ? 0 : 1
    d @max_mp

    if recipes = @recipes
      d recipes.size
      recipes.each_with_index do |rp, i|
        d rp.id
        d i &+ 1
      end
    else
      d 0
    end
  end
end
