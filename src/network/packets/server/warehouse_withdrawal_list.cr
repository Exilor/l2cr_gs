class Packets::Outgoing::WarehouseWithdrawalList < Packets::Outgoing::AbstractItemPacket
  PRIVATE = 1
  CLAN = 4
  CASTLE = 3 # not sure
  FREIGHT = 1

  @adena = 0i64
  @items : Concurrent::Array(L2ItemInstance)?

  def initialize(pc : L2PcInstance, type : Int32)
    @type = type
    unless wh = pc.active_warehouse
      warn { pc.name + " has no active warehouse." }
      return
    end

    @adena = pc.adena
    @items = wh.items
  end

  private def write_impl
    c 0x42

    h @type
    q @adena
    if items = @items
      h items.size
      items.each do |item|
        write_item(item)
        d item.l2id
      end
    else
      h 0
    end
  end
end
