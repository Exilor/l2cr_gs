class Packets::Outgoing::PlayerInGame < MMO::OutgoingPacket(LoginServerClient)
  initializer account: String

  def write
    c 0x02

    h 1
    s @account
  end
end
