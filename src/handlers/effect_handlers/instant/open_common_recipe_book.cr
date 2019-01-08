class EffectHandler::OpenCommonRecipeBook < AbstractEffect
  def instant?
    true
  end

  def on_start(info)
    return unless pc = info.effector.acting_player?
    unless pc.private_store_type.none?
      pc.send_packet(SystemMessageId::CANNOT_CREATED_WHILE_ENGAGED_IN_TRADING)
      return
    end

    RecipeController.request_book_open(pc, false)
  end
end
