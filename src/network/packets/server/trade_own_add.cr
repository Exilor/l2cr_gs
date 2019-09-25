class Packets::Outgoing::TradeOwnAdd < Packets::Outgoing::AbstractItemPacket
  initializer item : TradeItem

  def write_impl
    c 0x1a

    h 1
    h 0
    d @item.l2id
    d @item.item.display_id
    q @item.count
    h @item.item.type_2.id
    h @item.custom_type_1

    d @item.item.body_part
    h @item.enchant
    h 0x00
    h @item.custom_type_2

    write_item_elemental_and_enchant(ItemInfo.new(@item))
  end
end
