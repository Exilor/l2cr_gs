class Packets::Incoming::RequestExRemoveItemAttribute < GameClientPacket
  @l2id = 0
  @element = 0

  private def read_impl
    @l2id = d
    @element = d
  end

  private def run_impl
    return unless pc = active_char

    unless target_item = pc.inventory.get_item_by_l2id(@l2id)
      warn { "Item with l2id #{@l2id} not found in #{pc.name}'s inventory." }
      return
    end

    if target_item.elementals.nil? || target_item.get_elemental(@element).nil?
      warn { "Item doesn't have elements or doesn't have that element #{@element}." }
      return
    end

    if pc.reduce_adena("RemoveElement", get_price(target_item), pc, true)
      if target_item.equipped?
        target_item.get_elemental(@element).not_nil!.remove_bonus(pc)
      end

      target_item.clear_element_attr(@element)
      pc.send_packet(UserInfo.new(pc))

      iu = InventoryUpdate.modified(target_item)
      pc.send_packet(iu)

      if target_item.armor?
        real_element = Elementals.get_opposite_element(@element.to_i8)
      else
        real_element = @element
      end

      if target_item.enchant_level > 0
        if target_item.armor?
          sm = SystemMessage.s1_s2_s3_attribute_removed_resistance_to_s4_decreased
        else
          sm = SystemMessage.s1_s2_elemental_power_removed
        end

        sm.add_int(target_item.enchant_level)
      else
        if target_item.armor?
          sm = SystemMessage.s1_s2_attribute_removed_resistance_s3_decreased
        else
          sm = SystemMessage.s1_elemental_power_removed
        end
      end

      sm.add_item_name(target_item)
      if target_item.armor?
        sm.add_elemental(real_element)
        sm.add_elemental(Elementals.get_opposite_element(real_element.to_i8))
      end

      pc.send_packet(sm)
      cancel = ExBaseAttributeCancelResult.new(target_item.l2id, @element.to_i8)
      pc.send_packet(cancel)
    else
      pc.send_packet(SystemMessageId::YOU_DO_NOT_HAVE_ENOUGH_FUNDS_TO_CANCEL_ATTRIBUTE)
    end
  end

  private def get_price(item)
    case item.template.crystal_type
    when CrystalType::S
      if item.template.is_a?(L2Weapon)
        return 50000i64
      else
        return 40000i64
      end
    when CrystalType::S80
      if item.template.is_a?(L2Weapon)
        return 100000i64
      else
        return 80000i64
      end
    when CrystalType::S84
      if item.template.is_a?(L2Weapon)
        return 200000i64
      else
        return 160000i64
      end
    end


    0i64
  end
end
