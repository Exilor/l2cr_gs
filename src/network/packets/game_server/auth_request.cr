class Packets::Outgoing::AuthRequest < MMO::OutgoingPacket(LoginServerClient)
  initializer client : LoginServerClient

  def write
    c 0x01

    c client.request_id
    c client.accept_alternate ? 1 : 0
    c client.reserve_host ? 1 : 0

    h client.game_port

    d client.max_players

    d client.hex_id.size
    b client.hex_id
    s client.game_host
  end
end
