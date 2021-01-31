class Packets::Outgoing::GMViewWarehouseWithdrawList < Packets::Outgoing::AbstractItemPacket
  @player_name : String
  @items : Concurrent::Array(L2ItemInstance)
  @money : Int64

  def initialize(pc : L2PcInstance)
    @player_name = pc.name
    @items = pc.warehouse.items
    @money = pc.warehouse.adena
  end

  def initialize(clan : L2Clan)
    @player_name = clan.leader_name
    @items = clan.warehouse.items
    @money = clan.warehouse.adena
  end

  private def write_impl
    c 0x9b

    s @player_name
    q @money
    h @items.size
    @items.each do |item|
      write_item(item)
      d item.l2id
    end
  end
end
