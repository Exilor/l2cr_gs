class EffectHandler::OpenDwarfRecipeBook < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info : BuffInfo)
    return unless pc = info.effector.acting_player
    unless pc.private_store_type.none?
      pc.send_packet(SystemMessageId::CANNOT_CREATED_WHILE_ENGAGED_IN_TRADING)
      return
    end

    RecipeController.request_book_open(pc, true)
  end
end
