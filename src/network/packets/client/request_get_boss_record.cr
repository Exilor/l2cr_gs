class Packets::Incoming::RequestGetBossRecord < GameClientPacket
  no_action_request

  def read_impl
  end

  def run_impl
    warn "Not implemented."
  end
end
