class Packets::Incoming::RequestRecipeShopManageQuit < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    pc.private_store_type = PrivateStoreType::NONE
    pc.broadcast_user_info
    pc.stand_up
  end
end
