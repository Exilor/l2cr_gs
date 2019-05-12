class Packets::Incoming::RequestRecipeShopManageList < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    if pc.looks_dead?
      action_failed
      return
    end

    unless pc.private_store_type.none?
      pc.private_store_type = PrivateStoreType::NONE
      pc.broadcast_user_info
      if pc.sitting?
        pc.stand_up
      end
    end

    pc.send_packet(RecipeShopManageList.new(pc, true))
  end
end
