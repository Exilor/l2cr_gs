class Packets::Outgoing::SellListProcure < GameServerPacket
  @sell_list = {} of L2ItemInstance => Int64
  @money : Int64

  def initialize(pc : L2PcInstance, castle_id : Int32)
    @money = pc.adena

    CastleManorManager.get_crop_procure(castle_id, false).each do |crop|
      item = pc.inventory.get_item_by_item_id(crop.id)
      if item && item.amount > 0
        @sell_list[item] = c.amount
      end
    end
  end

  private def write_impl
    c 0xef

    q @money
    d 0
    h @sell_list.size
    @sell_list.each do |item, count|
      h item.template.type_1.id
      d item.l2id
      d item.display_id
      q count
      h item.template.type_2.id
      h 0
      q 0
    end
  end
end
