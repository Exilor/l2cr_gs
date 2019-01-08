class Packets::Incoming::RequestGoToLobby < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    csi = CharSelectionInfo.new(client.account_name, client.session_id.play_ok_1)
    client.send_packet(csi)
  end
end
