class Packets::Outgoing::BuyList < GameServerPacket
  initializer list: L2BuyList, money: Int64, tax_rate: Float64

  def write_impl
    c 0xfe
    h 0xb7

    d 0x00
    q @money
    d @list.list_id

    h @list.size

    @list.products.each do |product|
      if product.count > 0 || !product.limited_stock?
        d product.item_id
        d product.item_id
        d 0
        q product.count < 0 ? 0 : product.count
        h product.item.type_2.id
        h product.item.type_1.id
        h 0x00 # equipped
        d product.item.body_part
        h product.item.default_enchant_level
        h 0x00 # custom type
        d 0x00 # augment
        d -1 # mana
        d -9999 # time
        h 0x00 # element type
        h 0x00 # element power
        6.times { h 0x00 }
        3.times { h 0x00 } # enchant effects

        if 3960 <= product.item_id <= 4024
          q product.price * Config.rate_siege_guards_price * (1 + @tax_rate)
        else
          q product.price * (1 + @tax_rate)
        end
      end
    end
  end
end
