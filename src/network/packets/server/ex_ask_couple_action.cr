class Packets::Outgoing::ExAskCoupleAction < GameServerPacket
  initializer char_id : Int32, action_id : Int32

  private def write_impl
    c 0xfe
    h 0xbb

    d @action_id
    d @char_id
  end
end
