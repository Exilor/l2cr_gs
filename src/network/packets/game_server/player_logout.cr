class Packets::Outgoing::PlayerLogout < MMO::OutgoingPacket(LoginServerThread)
  initializer account : String

  def write
    c 0x03
    s @account
  end
end
