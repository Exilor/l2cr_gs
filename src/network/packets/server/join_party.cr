class Packets::Outgoing::JoinParty < GameServerPacket
  initializer response: Int32

  def write_impl
    c 0x3a
    d @response
  end
end
