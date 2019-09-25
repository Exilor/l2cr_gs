class Packets::Outgoing::PlayerAuthRequest < MMO::OutgoingPacket(LoginServerClient)
  initializer account : String, session_key : SessionKey

  def write
    c 0x05

    s @account

    d @session_key.play_ok_1
    d @session_key.play_ok_2
    d @session_key.login_ok_1
    d @session_key.login_ok_2
  end
end
