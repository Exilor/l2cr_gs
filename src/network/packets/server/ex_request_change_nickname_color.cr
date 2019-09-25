class Packets::Outgoing::ExRequestChangeNicknameColor < GameServerPacket
  initializer item_l2id : Int32

  def write_impl
    c 0xfe
    h 0x83

    d @item_l2id
  end
end
