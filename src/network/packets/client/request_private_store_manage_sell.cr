class Packets::Incoming::RequestPrivateStoreManageSell < GameClientPacket
  no_action_request

  def read_impl
    # L2J hasn't implemented this.
  end

  def run_impl
    return unless pc = active_char

    if pc.looks_dead? || pc.in_olympiad_mode?
      action_failed
      return
    end
  end
end
