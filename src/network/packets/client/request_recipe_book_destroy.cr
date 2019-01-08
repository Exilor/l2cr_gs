class Packets::Incoming::RequestRecipeBookDestroy < GameClientPacket
  @id = 0

  def read_impl
    @id = d
  end

  def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("RecipeDestroy")
      debug "Flood detected."
      return
    end

    unless rp = RecipeData.get_recipe_list(@id)
      warn "Recipe with ID #{@id} not found."
      return
    end

    pc.unregister_recipe_list(@id)

    response = RecipeBookItemList.new(rp.dwarven_recipe?, pc.max_mp)

    if rp.dwarven_recipe?
      response.add_recipes(pc.dwarven_recipe_book)
    else
      response.add_recipes(pc.common_recipe_book)
    end

    send_packet(response)
  end
end
