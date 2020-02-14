class Packets::Incoming::RequestQuestList < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    send_packet(QuestList.new)
  end
end
