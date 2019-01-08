class Packets::Outgoing::L2FriendSay < GameServerPacket
  initializer sender: String, receiver: String, message: String

  def write_impl
    c 0x78

    d 0 # unk
    s @receiver
    s @sender
    s @message
  end
end
