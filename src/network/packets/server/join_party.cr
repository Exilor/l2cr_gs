class Packets::Outgoing::JoinParty < GameServerPacket
  initializer response : Int32

  private def write_impl
    c 0x3a
    d @response
  end
end
