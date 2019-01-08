class Packets::Incoming::RequestCharacters < MMO::IncomingPacket(LoginServerClient)
  @account = ""

  def read
    @account = s
  end

  def run
    client.get_chars_on_server(@account)
  end
end
