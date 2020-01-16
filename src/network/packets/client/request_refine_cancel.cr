class Packets::Incoming::RequestRefineCancel < Packets::Incoming::AbstractRefinePacket
  @target_item_obj_id = 0

  private def read_impl
    @target_item_obj_id = d
  end

  private def run_impl
    return unless pc = active_char

    item = pc.inventory.get_item_by_l2id(@target_item_obj_id)
    unless item
      pc.send_packet(ExVariationCancelResult::FAIL)
      return
    end

    if item.owner_id != pc.l2id
      Util.punish(pc, "tried to cancel the augmentation of an item he doesn't own.")
      return
    end

    unless item.augmented?
      pc.send_packet(SystemMessageId::AUGMENTATION_REMOVAL_CAN_ONLY_BE_DONE_ON_AN_AUGMENTED_ITEM)
      pc.send_packet(ExVariationCancelResult::FAIL)
      return
    end

    price = 0
    case item.template.crystal_type
    when CrystalType::C
      if item.crystal_count < 1720
        price = 95_000
      elsif item.crystal_count < 2452
        price = 150_000
      else
        price = 210_000
      end
    when CrystalType::B
      if item.crystal_count < 1746
        price = 240_000
      else
        price = 270_000
      end
    when CrystalType::A
      if item.crystal_count < 2160
        price = 330_000
      elsif item.crystal_count < 2824
        price = 390_000
      else
        price = 420_000
      end
    when CrystalType::S
      price = 480_000
    when CrystalType::S80, CrystalType::S84
      price = 920_000
    else
      pc.send_packet(ExVariationCancelResult::FAIL)
      return
    end

    unless pc.reduce_adena("RequestRefineCancel", price.to_i64, nil, true)
      pc.send_packet(ExVariationCancelResult::FAIL)
      pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      return
    end

    pc.disarm_weapons if item.equipped?

    item.remove_augmentation

    pc.send_packet(ExVariationCancelResult::SUCCESS)

    pc.send_packet(InventoryUpdate.modified(item))
  end
end
