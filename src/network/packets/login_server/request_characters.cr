require "../login_server_packet"

class Packets::Incoming::RequestCharacters < LoginServerPacket
  @account = ""

  private def read_impl
    @account = s
  end

  private def run_impl
    client.get_chars_on_server(@account)
  end
end
