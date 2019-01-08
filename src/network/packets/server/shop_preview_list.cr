class Packets::Outgoing::ShopPreviewList < GameServerPacket
  @expertise = 0

  initializer list: Enumerable(Product), list_id: Int32, adena: Int64

  def initialize(lst : L2BuyList, @adena : Int64, @expertise : Int32)
    @list_id = lst.list_id
    @list = lst.products
  end

  def write_impl
    c 0xf5
    c 0xc0
    c 0x13
    h 0
    q @adena
    d @list_id
    new_length = @list.count do |product|
      item = product.item
      item.crystal_type.to_i <= @expertise && item.equippable?
    end
    debug "Sending #{new_length} items."
    h new_length
    @list.each do |product|
      item = product.item
      if item.crystal_type.to_i <= @expertise && item.equippable?
        d product.item_id
        h item.type_2.id

        if item.type_1 != ItemType1::ITEM_QUESTITEM_ADENA
          h item.body_part
        else
          h 0
        end

        q Config.wear_price
      end
    end
  end
end
