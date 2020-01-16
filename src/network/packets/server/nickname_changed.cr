class Packets::Outgoing::NicknameChanged < GameServerPacket
  initializer char : L2Character

  private def write_impl
    c 0xcc

    d @char.l2id
    s @char.title
  end
end
