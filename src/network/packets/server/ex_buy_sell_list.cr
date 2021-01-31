class Packets::Outgoing::ExBuySellList < Packets::Outgoing::AbstractItemPacket
  @sell_list : Array(L2ItemInstance)
  @refund_list : Concurrent::Array(L2ItemInstance)?

  def initialize(pc : L2PcInstance, done : Bool)
    @done = done
    @sell_list = pc.inventory.get_available_items(false, false, false)
    if pc.has_refund?
      @refund_list = pc.refund.items
    end
  end

  private def write_impl
    c 0xfe
    h 0xb7

    d 0x01

    if @sell_list
      h @sell_list.size
      @sell_list.each do |item|
        write_item(item)
        q item.template.reference_price / 2
      end
    else
      h 0x00
    end

    refund_list = @refund_list

    if refund_list && !refund_list.empty?
      h refund_list.size
      refund_list.each_with_index do |item, i|
        write_item(item)
        d i
        q (item.template.reference_price / 2) * item.count
      end
    else
      h 0x00
    end

    c @done ? 0x01 : 0x00
  end
end
