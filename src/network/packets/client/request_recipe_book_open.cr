class Packets::Incoming::RequestRecipeBookOpen < GameClientPacket
  @dwarven = false

  private def read_impl
    @dwarven = d == 0
  end

  private def run_impl
    return unless pc = active_char

    if pc.casting_now? || pc.casting_simultaneously_now?
      send_packet(SystemMessageId::NO_RECIPE_BOOK_WHILE_CASTING)
      return
    end

    if pc.active_requester
      pc.send_message("You may not alter your recipe book while trading.")
      return
    end

    RecipeController.request_book_open(pc, @dwarven)
  end
end
