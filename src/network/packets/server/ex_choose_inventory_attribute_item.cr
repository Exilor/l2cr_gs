class Packets::Outgoing::ExChooseInventoryAttributeItem < GameServerPacket
  @item_id : Int32

  def initialize(item : L2ItemInstance)
    @item_id = item.display_id
    @attribute = Elementals.get_item_element(@item_id)
    if @attribute == Elementals::NONE
      raise "Undefined attribute item: #{item}"
    end
    @level = Elementals.get_max_element_level(@item_id)
  end

  def write_impl
    c 0xfe
    h 0x62

    d @item_id
    d @attribute == Elementals::FIRE ? 1 : 0
    d @attribute == Elementals::WATER ? 1 : 0
    d @attribute == Elementals::WIND ? 1 : 0
    d @attribute == Elementals::EARTH ? 1 : 0
    d @attribute == Elementals::HOLY ? 1 : 0
    d @attribute == Elementals::DARK ? 1 : 0
    d @level
  end
end
