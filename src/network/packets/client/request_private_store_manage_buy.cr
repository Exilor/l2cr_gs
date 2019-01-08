class Packets::Incoming::RequestPrivateStoreManageBuy < GameClientPacket
  no_action_request

  def read_impl
    # no-op
  end

  def run_impl
    if pc = active_char
      pc.try_open_private_buy_store
    end
  end
end
