class Packets::Incoming::RequestExEnchantItemAttribute < GameClientPacket
  @l2id = 0

  private def read_impl
    @l2id = d
  end

  private def run_impl
    return unless pc = active_char

    if @l2id == 0xFFFFFFFF
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      send_packet(SystemMessageId::ELEMENTAL_ENHANCE_CANCELED)
      return
    end

    unless pc.online?
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      return
    end

    unless pc.private_store_type.none?
      pc.cancel_active_trade
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      pc.send_message("You cannot add elemental power while trading.")
      return
    end

    inv = pc.inventory
    item = inv.get_item_by_l2id(@l2id)
    stone = inv.get_item_by_l2id(pc.active_enchant_attr_item_id)

    unless item && stone
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      send_packet(SystemMessageId::ELEMENTAL_ENHANCE_CANCELED)
      return
    end

    unless item.elementable?
      send_packet(SystemMessageId::ELEMENTAL_ENHANCE_REQUIREMENT_NOT_SUFFICIENT)
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      return
    end

    case item.item_location
    when ItemLocation::INVENTORY, ItemLocation::PAPERDOLL
      if item.owner_id != pc.l2id
        pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
        return
      end
    else
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      Util.punish(pc, "tried to add an attribute to an item while the previous attribute enchanting didn't finish.")
      return
    end

    stone_id = stone.id
    element_to_add = Elementals.get_item_element(stone_id)

    if item.armor?
      element_to_add = Elementals.get_opposite_element(element_to_add)
    end

    opposite_element = Elementals.get_opposite_element(element_to_add)

    old_element = item.get_elemental(element_to_add)
    element_value = old_element.try &.value || 0
    limit = get_limit(item, stone_id)
    power_to_add = get_power_to_add(stone_id, element_value, item)

    if item.weapon? && old_element && old_element.element != element_to_add
      if old_element.element != -2
        send_packet(SystemMessageId::ANOTHER_ELEMENTAL_POWER_ALREADY_ADDED)
        pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
        return
      end
    end

    if item.armor? && item.get_elemental(element_to_add).nil?
      if elementals = item.elementals
        if elementals.size >= 3
          send_packet(SystemMessageId::ANOTHER_ELEMENTAL_POWER_ALREADY_ADDED)
          pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
          return
        end
      end
    end

    if item.armor?
      item.elementals.try &.each do |elm|
        if elm.element == opposite_element
          pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
          Util.punish(pc, "tried to add the element opposite of the item's element.")
          return
        end
      end
    end

    new_power = element_value + power_to_add
    if new_power > limit
      new_power = limit
      power_to_add = limit - element_value
    end

    if power_to_add <= 0
      send_packet(SystemMessageId::ELEMENTAL_ENHANCE_CANCELED)
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      return
    end

    unless pc.destroy_item("AttrEnchant", stone, 1, pc, true)
      send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      Util.punish(pc, "tried to do element enchant with a stone he doesn't own.")
      pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
      return
    end

    success = false

    case Elementals.get_item_elemental(stone_id).not_nil!.type
    when Elementals::ElementalItemType::Stone, Elementals::ElementalItemType::Roughore
      success = Rnd.rand(100) < Config.enchant_chance_element_stone
    when Elementals::ElementalItemType::Crystal
      success = Rnd.rand(100) < Config.enchant_chance_element_crystal
    when Elementals::ElementalItemType::Jewel
      success = Rnd.rand(100) < Config.enchant_chance_element_jewel
    when Elementals::ElementalItemType::Energy
      success = Rnd.rand(100) < Config.enchant_chance_element_energy
    end

    if success
      real_element = item.armor? ? opposite_element : element_to_add

      if item.enchant_level == 0
        if item.armor?
          sm = SystemMessage.the_s2_attribute_was_successfully_bestowed_on_s1_res_to_s3_increased
        else
          sm = SystemMessage.elemental_power_s2_successfully_added_to_s1
        end

        sm.add_item_name(item)
        sm.add_elemental(real_element)

        if item.armor?
          sm.add_elemental(Elementals.get_opposite_element(real_element))
        end
      else
        if item.armor?
          sm = SystemMessage.the_s3_attribute_bestowed_on_s1_s2_resistance_to_s4_increased
        else
          sm = SystemMessage.elemental_power_s3_successfully_added_to_s1_s2
        end

        sm.add_int(item.enchant_level)
        sm.add_item_name(item)
        sm.add_elemental(real_element)

        if item.armor?
          sm.add_elemental(Elementals.get_opposite_element(real_element))
        end
      end

      send_packet(sm)
      item.set_element_attr(element_to_add, new_power)
      if item.equipped?
        item.update_element_attr_bonus(pc)
      end

      pc.send_packet(InventoryUpdate.modified(item))
    else
      send_packet(SystemMessageId::FAILED_ADDING_ELEMENTAL_POWER)
    end

    send_packet(ExAttributeEnchantResult.new(power_to_add))
    send_packet(UserInfo.new(pc))
    send_packet(ExBrExtraUserInfo.new(pc))
    pc.active_enchant_attr_item_id = L2PcInstance::ID_NONE
  end

  private def get_limit(item, stone_id)
    return 0 unless element_item = Elementals.get_item_elemental(stone_id)

    if item.weapon?
      Elementals::WEAPON_VALUES[element_item.type.max_level]
    else
      Elementals::ARMOR_VALUES[element_item.type.max_level]
    end
  end

  private def get_power_to_add(stone_id, old_value, item)
    if Elementals.get_item_element(stone_id) != Elementals::NONE
      if item.weapon?
        if old_value == 0
          return Elementals::FIRST_WEAPON_BONUS
        else
          return Elementals::NEXT_WEAPON_BONUS
        end
      elsif item.armor?
        return Elementals::ARMOR_BONUS
      end
    end

    0
  end
end
