class Packets::Incoming::RequestPrivateStoreManageBuy < GameClientPacket
  no_action_request

  private def read_impl
    # no-op
  end

  private def run_impl
    if pc = active_char
      pc.try_open_private_buy_store
    end
  end
end
