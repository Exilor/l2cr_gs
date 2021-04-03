class Packets::Incoming::RequestEx2ndPasswordCheck < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    if !SecondaryAuthData.enabled? || client.secondary_auth.authed?
      send_packet(Ex2ndPasswordCheck::OK)
      return
    end

    client.secondary_auth.open_dialog
  end
end
