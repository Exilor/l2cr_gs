class Packets::Incoming::RequestRecipeShopMakeItem < GameClientPacket
  @id = 0
  @recipe_id = 0

  private def read_impl
    @id = d
    @recipe_id = d
    # unk = q
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.manufacture.try_perform_action("RecipeShopMake")
      debug "Flood detected."
      return
    end

    unless crafter = L2World.get_player(@id)
      warn "Player with ID #{@id} not found."
      return
    end

    unless pc.private_store_type.none?
      pc.send_message("You cannot create items while trading.")
      return
    end

    unless crafter.private_store_type.manufacture?
      return
    end

    if pc.in_craft_mode? || crafter.in_craft_mode?
      pc.send_message("You are currently in craft mode.")
      return
    end

    if Util.in_range?(L2Npc::INTERACTION_DISTANCE, pc, crafter, true)
      RecipeController.request_manufacture_item(crafter, @recipe_id, pc)
    end
  end
end
