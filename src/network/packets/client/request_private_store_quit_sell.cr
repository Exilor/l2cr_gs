class Packets::Incoming::RequestPrivateStoreQuitSell < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char

    pc.private_store_type = PrivateStoreType::NONE
    pc.stand_up
    pc.broadcast_user_info
  end
end
