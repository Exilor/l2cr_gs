class Packets::Outgoing::FriendAddRequest < GameServerPacket
  initializer requestor_name: String

  def write_impl
    c 0x83

    s @requestor_name
    d 0
  end
end
