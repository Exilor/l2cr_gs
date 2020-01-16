class Packets::Outgoing::RecipeItemMakeInfo < GameServerPacket
  def initialize(@id : Int32, @pc : L2PcInstance, @success : Bool = true)
  end

  private def write_impl
    if recipe = RecipeData.get_recipe_list(@id)
      c 0xdd

      d @id
      d recipe.dwarven_recipe? ? 0 : 1
      d @pc.current_mp.to_i
      d @pc.max_mp
      d @success ? 1 : 0
    else
      warn "#{active_char} requested recipe #{@id} but it wasn't found."
    end
  end
end
