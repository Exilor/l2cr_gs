class Packets::Outgoing::WareHouseDepositList < Packets::Outgoing::AbstractItemPacket
  PRIVATE = 1
  CLAN = 4
  CASTLE = 3 # not sure
  FREIGHT = 1

  @adena : Int64
  @items : Array(L2ItemInstance)

  def initialize(pc : L2PcInstance, type : Int32)
    @adena = pc.adena
    @type = type
    is_private = type == PRIVATE
    @items = pc.inventory.get_available_items(true, is_private, false)
    @items.select! &.depositable?(is_private)
  end

  private def write_impl
    c 0x41

    h @type
    q @adena
    h @items.size
    @items.each do |item|
      write_item(item)
      d item.l2id
    end
  end
end
