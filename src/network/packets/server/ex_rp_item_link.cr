class Packets::Outgoing::ExRpItemLink < GameServerPacket
  initializer item : L2ItemInstance

  private def write_impl
    c 0xfe
    h 0x6c

    d @item.l2id
    d @item.display_id
    d @item.location_slot
    q @item.count
    h @item.template.type_2.id
    h @item.custom_type_1
    h @item.equipped? ? 1 : 0
    d @item.template.body_part
    h @item.enchant_level
    h @item.custom_type_2

    if aug = @item.augmentation
      d aug.augmentation_id
    else
      d 0
    end

    d @item.mana
    d @item.time_limited_item? ? @item.remaining_time // 1000 : -9999
    h @item.attack_element_type
    h @item.attack_element_power
    6.times { |i| h @item.get_element_def_attr(i) }
    @item.enchant_options.each { |op| h op }
  end
end
