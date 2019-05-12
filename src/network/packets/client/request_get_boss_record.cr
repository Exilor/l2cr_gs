class Packets::Incoming::RequestGetBossRecord < GameClientPacket
  no_action_request

  private def read_impl
  end

  private def run_impl
    warn "Not implemented."
  end
end
