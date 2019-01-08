class Packets::Incoming::RequestBuySellUIClose < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char

    unless pc.inventory_disabled?
      pc.send_packet(ItemList.new(pc, true))
    end
  end
end
