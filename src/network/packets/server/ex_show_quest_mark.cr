class Packets::Outgoing::ExShowQuestMark < GameServerPacket
  initializer quest_id : Int32

  def write_impl
    c 0xfe
    h 0x21

    d @quest_id
  end
end
