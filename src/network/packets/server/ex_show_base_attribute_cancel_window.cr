class Packets::Outgoing::ExShowBaseAttributeCancelWindow < GameServerPacket
  @items : Array(L2ItemInstance)
  @price = 0i64

  def initialize(pc : L2PcInstance)
    @items = pc.inventory.element_items
  end

  private def write_impl
    c 0xfe
    h 0x74

    d @items.size
    @items.each do |item|
      d item.l2id
      q get_price(item)
    end
  end

  private def get_price(item : L2ItemInstance) : Int64
    case item.template.crystal_type
    when .s?
      @price = item.template.is_a?(L2Weapon) ? 50_000_i64 : 40_000_i64
    when .s80?
      @price = item.template.is_a?(L2Weapon) ? 100_000_i64 : 80_000_i64
    when .s84?
      @price = item.template.is_a?(L2Weapon) ? 200_000_i64 : 160_000_i64
    else
      # [automatically added else]
    end


    @price
  end
end
