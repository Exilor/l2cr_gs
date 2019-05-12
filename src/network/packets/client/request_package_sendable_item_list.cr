class Packets::Incoming::RequestPackageSendableItemList < GameClientPacket
  @l2id = 0

  private def read_impl
    @l2id = d
  end

  private def run_impl
    return unless pc = active_char
    items = pc.inventory.get_available_items(true, true, true)
    pc.send_packet(PackageSendableList.new(items, @l2id))
  end
end
