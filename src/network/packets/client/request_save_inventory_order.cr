class Packets::Incoming::RequestSaveInventoryOrder < GameClientPacket
  no_action_request

  private LIMIT = 125

  private record InvOrder, l2id : Int32, order : Int16

  @orders : Slice(InvOrder)?

  private def read_impl
    size = Math.min(d, LIMIT)
    @orders = Slice.new(size) { InvOrder.new(d, d.to_i16) }
  end

  private def run_impl
    return unless pc = active_char
    return unless orders = @orders
    inv = pc.inventory
    orders.each do |ord|
      item = inv.get_item_by_l2id(ord.l2id)
      if item && item.item_location.inventory?
        item.set_item_location(ItemLocation::INVENTORY, ord.order.to_i32)
      end
    end
  end
end
