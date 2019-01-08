class Packets::Incoming::RequestRefine < Packets::Incoming::AbstractRefinePacket
  @target_item_obj_id = 0
  @refiner_item_obj_id = 0
  @gemstone_item_obj_id = 0
  @gemstone_count = 0i64

  def read_impl
    @target_item_obj_id = d
    @refiner_item_obj_id = d
    @gemstone_item_obj_id = d
    @gemstone_count = q
  end

  def run_impl
    return unless pc = active_char
    return unless target_item = pc.inventory.get_item_by_l2id(@target_item_obj_id)
    return unless refiner_item = pc.inventory.get_item_by_l2id(@refiner_item_obj_id)
    return unless gemstone_item = pc.inventory.get_item_by_l2id(@gemstone_item_obj_id)

    unless valid?(pc, target_item, refiner_item, gemstone_item)
      debug "#valid? returned false."
      pc.send_packet(ExVariationResult::STATIC_PACKET)
      pc.send_packet(SystemMessageId::AUGMENTATION_FAILED_DUE_TO_INAPPROPRIATE_CONDITIONS)
      return
    end

    return unless ls = get_life_stone(refiner_item.id)

    ls_level = ls.level
    ls_grade = ls.grade

    if @gemstone_count != get_gemstone_count(target_item.template.item_grade, ls_grade)
      debug "Incorrect gemstone count: #{@gemstone_count}/#{get_gemstone_count(target_item.template.item_grade, ls_grade)}."
      pc.send_packet(ExVariationResult::STATIC_PACKET)
      pc.send_packet(SystemMessageId::AUGMENTATION_FAILED_DUE_TO_INAPPROPRIATE_CONDITIONS)
      return
    end

    if target_item.equipped?
      unequipped = pc.inventory.unequip_item_in_slot_and_record(target_item.location_slot)
      iu = InventoryUpdate.new
      unequipped.each { |i| iu.add_modified_item(i) }
      pc.send_packet(iu)
      pc.broadcast_user_info
    end

    unless pc.destroy_item("RequestRefine", refiner_item, 1, nil, false)
      debug "Destroying refiner item failed."
      return
    end

    unless pc.destroy_item("RequestRefine", gemstone_item, @gemstone_count, nil, false)
      debug "Destroying the gemstones failed."
      return
    end

    aug = AugmentationData.generate_random_augmentation(ls_level, ls_grade, target_item.template.body_part, refiner_item.id, target_item)
    unless aug
      warn "An augmentation wasn't successfully created."
      return
    end
    target_item.set_augmentation(aug)

    stat12 = 0x0000FFFF & aug.augmentation_id
    stat34 = aug.augmentation_id >> 16
    pc.send_packet(ExVariationResult.new(stat12, stat34, 1))

    # iu = InventoryUpdate.new
    # iu.add_modified_item target_item
    # pc.send_packet(iu)
    pc.send_packet(InventoryUpdate.modified(target_item))

    pc.send_packet(StatusUpdate.current_load(pc))
  end
end
