require "../../../models/trade_item"

abstract class Packets::Outgoing::AbstractItemPacket < GameServerPacket
  private def write_item(item : TradeItem | L2ItemInstance)
    write_item(ItemInfo.new(item))
  end

  private def write_item(item : ItemInfo)
    d item.l2id
    d item.template.display_id # ItemId
    d item.location # T1
    q item.count # Quantity
    h item.template.type_2.id # Item Type 2 : 00-weapon, 01-shield/armor, 02-ring/earring/necklace, 03-questitem, 04-adena, 05-item
    h item.custom_type_1 # Filler (always 0)
    h item.equipped # Equipped : 00-No, 01-yes
    d item.template.body_part # Slot : 0006-lr.ear, 0008-neck, 0030-lr.finger, 0040-head, 0100-l.hand, 0200-gloves, 0400-chest, 0800-pants, 1000-feet, 4000-r.hand, 8000-r.hand
    h item.enchant # Enchant level (pet level shown in control item)
    h item.custom_type_2 # Pet name exists or not shown in control item
    d item.augmentation_bonus
    d item.mana
    d item.time
    write_item_elemental_and_enchant(item)
  end

  private def write_item_elemental_and_enchant(item : ItemInfo)
    h item.attack_element_type
    h item.attack_element_power
    6.times { |i| h item.get_element_def_attr(i) }
    item.enchant_options.each { |op| h op }
  end

  private def write_inventory_block(inv : PcInventory)
    if blocked = inv.block_items
      h blocked.size
      c inv.block_mode
      blocked.each { |i| d i }
    else
      h 0x00
    end
  end
end
