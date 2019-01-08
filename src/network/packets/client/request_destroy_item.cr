class Packets::Incoming::RequestDestroyItem < GameClientPacket
  @l2id = 0
  @count = 0i64

  def read_impl
    @l2id = d
    @count = q
  end

  def run_impl
    return unless pc = active_char

    if @count <= 0
      if @count < 0
        Util.punish(pc, "tried to destroy #{@count} items.")
        warn "#{pc} requested to destroy #{@count} items."
      end
      return
    end

    unless flood_protectors.transaction.try_perform_action("destroy")
      pc.send_message("You are destroying items too fast.")
      return
    end

    if pc.processing_transaction? || !pc.private_store_type.none?
      pc.send_packet(SystemMessageId::CANNOT_TRADE_DISCARD_DROP_ITEM_WHILE_IN_SHOPMODE)
      return
    end

    unless item = pc.inventory.get_item_by_l2id(@l2id)
      pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
      return
    end

    if pc.casting_now?
      if pc.current_skill.try &.skill.item_consume_id == item.id
        pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
        return
      end
    end

    if pc.casting_simultaneously_now?
      if pc.last_simultaneous_skill_cast.try &.item_consume_id == item.id
        pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
        return
      end
    end

    item_id = item.id

    if !pc.override_destroy_all_items? && !item.destroyable? || CursedWeaponsManager.cursed?(item_id)
      if item.hero_item?
        pc.send_packet(SystemMessageId::HERO_WEAPONS_CANT_DESTROYED)
      else
        pc.send_packet(SystemMessageId::CANNOT_DISCARD_THIS_ITEM)
      end
      return
    end

    if !item.stackable? && @count > 1
      Util.punish(pc, "tried to destroy a non-stackable item with object id #{@l2id} with count greater than 1 (#{@count}).")
      return
    end

    unless pc.inventory.can_manipulate_with_item_id?(item.id)
      pc.send_message("You cannot use this item.")
      return
    end

    count = Math.min(@count, item.count)

    if item.template.pet_item?
      if pc.has_summon? && pc.summon!.control_l2id == @l2id
        pc.summon!.unsummon(pc)
      end

      sql = "DELETE FROM pets WHERE item_obj_id=?"
      GameDB.exec(sql, @l2id)
    end

    if item.time_limited_item?
      item.end_of_life
    end

    if item.equipped?
      if item.enchanted?
        sm = SystemMessage.equipment_s1_s2_removed
        sm.add_int(item.enchant_level)
        sm.add_item_name(item)
        pc.send_packet(sm)
      else
        sm = SystemMessage.s1_disarmed
        sm.add_item_name(item)
        pc.send_packet(sm)
      end

      unequipped = pc.inventory.unequip_item_in_slot_and_record(item.location_slot)

      iu = InventoryUpdate.new
      unequipped.each do |item|
        iu.add_modified_item(item)
      end
      pc.send_packet(iu)
      # if unequipped.size == 1
      #   pc.send_packet(InventoryUpdate.modified(*unequipped))
      # elsif unequipped.size > 1
      #   iu = InventoryUpdate.new
      #   unequipped.each { |item| iu.add_modified_item(item) }
      #   pc.send_packet(iu)
      # end
    end

    deleted_item = pc.inventory.destroy_item("Destroy", item, count, pc, nil)
    return unless deleted_item

    if Config.force_inventory_update
      send_packet(ItemList.new(pc, true))
    else
      if deleted_item.count == 0
        pc.send_packet(InventoryUpdate.removed(deleted_item))
      else
        pc.send_packet(InventoryUpdate.modified(deleted_item))
      end
    end

    pc.send_packet(StatusUpdate.current_load(pc))
  end
end
