class Packets::Outgoing::ChangeAccessLevel < MMO::OutgoingPacket(LoginServerThread)
  initializer player_name : String, access : Int32

  def write
    c 0x04

    d @access
    s @player_name
  end
end
