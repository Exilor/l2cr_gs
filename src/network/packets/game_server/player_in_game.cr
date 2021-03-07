class Packets::Outgoing::PlayerInGame < MMO::OutgoingPacket(LoginServerThread)
  initializer account : String

  def write
    c 0x02
    s @account
  end
end
