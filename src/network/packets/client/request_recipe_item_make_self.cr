class Packets::Incoming::RequestRecipeItemMakeSelf < GameClientPacket
  @id = 0

  private def read_impl
    @id = d
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.manufacture.try_perform_action("RecipeMakeSelf")
      debug "Flood detected."
      return
    end

    unless pc.private_store_type.none?
      pc.send_message("You cannot create items while trading.")
      return
    end

    if pc.in_craft_mode?
      pc.send_message("You are currently in Craft Mode.")
      return
    end

    RecipeController.request_make_item(pc, @id)
  end
end
