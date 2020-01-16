class Packets::Incoming::RequestSaveInventoryOrder < GameClientPacket
  no_action_request

  private LIMIT = 125

  # Since the game can only handle setting the order on the first 125 inventory
  # slots, the possible range is 0..125 so a byte will suffice.
  private record InventoryOrder, l2id : Int32, slot : UInt8

  @orders = Slice(InventoryOrder).empty

  private def read_impl
    size = Math.min(d, LIMIT)
    @orders = Slice.new(size) { InventoryOrder.new(d, d.to_u8) }
  end

  private def run_impl
    return unless pc = active_char
    inv = pc.inventory
    @orders.each do |ord|
      item = inv.get_item_by_l2id(ord.l2id)
      if item && item.item_location.inventory?
        item.set_item_location(ItemLocation::INVENTORY, ord.slot.to_i32)
      end
    end
  end
end
