class Packets::Outgoing::PlayerTracert < MMO::OutgoingPacket(LoginServerThread)
  initializer account : String, address : Slice(String)

  def write
    c 0x07

    s @account
    @address.each { |part| s part }
  end
end
