require "../game_server_packet"

class Packets::Outgoing::KeyPacket < GameServerPacket
  initializer key : Bytes, response : Bool

  private def write_impl
    c 0x2e

    c @response ? 1 : 0
    b @key[0, 8]
    d 0x01
    d 0x01 # server id
    c 0x01
    d 0x00 # obfuscation key
  end
end
