class Packets::Incoming::RequestRecipeShopMakeInfo < GameClientPacket
  @l2id = 0
  @recipe_id = 0

  private def read_impl
    @l2id = d
    @recipe_id = d
  end

  private def run_impl
    return unless pc = active_char

    unless shop = L2World.get_player(@l2id)
      warn "Player with ID #{@l2id} not found."
      return
    end

    unless shop.private_store_type.manufacture?
      return
    end

    send_packet(RecipeShopItemInfo.new(shop, @recipe_id))
  end
end
