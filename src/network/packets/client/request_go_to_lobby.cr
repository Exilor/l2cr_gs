class Packets::Incoming::RequestGoToLobby < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    csi = CharSelectionInfo.new(client.account_name, client.session_id.play_ok_1)
    client.send_packet(csi)
  end
end
