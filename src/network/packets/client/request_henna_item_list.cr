class Packets::Incoming::RequestHennaItemList < GameClientPacket
  private def read_impl
    # @unknown = d
  end

  private def run_impl
    return unless pc = active_char
    pc.send_packet(HennaEquipList.new(pc))
  end
end
