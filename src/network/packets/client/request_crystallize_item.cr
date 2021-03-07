class Packets::Incoming::RequestCrystallizeItem < GameClientPacket
  @l2id = 0
  @count = 0i64

  private def read_impl
    @l2id = d
    @count = q
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("crystallize")
      pc.send_message("You are crystallizing too fast.")
      return
    end

    if @count <= 0
      Util.punish(pc, "tried to crystallize x#{@count} of an item.")
      return
    end

    if !pc.private_store_type.none? || pc.in_crystallize?
      send_packet(SystemMessageId::CANNOT_TRADE_DISCARD_DROP_ITEM_WHILE_IN_SHOPMODE)
      return
    end

    skill_level = pc.get_skill_level(CommonSkill::CRYSTALLIZE.id)

    if skill_level <= 0
      send_packet(SystemMessageId::CRYSTALLIZE_LEVEL_TOO_LOW)
      action_failed
      if !pc.race.dwarf? && pc.class_id.to_i != 117 && pc.class_id.to_i != 55
        warn { "Player #{pc} used crystallize with class #{pc.class_id}." }
      end
      return
    end

    inv = pc.inventory
    unless item = inv.get_item_by_l2id(@l2id)
      action_failed
      return
    end

    return if item.hero_item?

    if @count > item.count
      @count = item.count
    end

    if item.shadow_item? || item.time_limited_item?
      return
    end

    if !item.template.crystallizable? ||item.template.crystal_count <= 0 || item.template.crystal_type.none?
      warn { "Player #{pc} tried to crystallize #{item.name}, which cannot be crystallized." }
      return
    end

    unless inv.can_manipulate_with_item_id?(item.id)
      pc.send_message("You cannot use this item.")
      return
    end

    can_crystallize = true

    case item.template.item_grade_s_plus
    when .c?
      can_crystallize = false if skill_level <= 1
    when .b?
      can_crystallize = false if skill_level <= 2
    when .a?
      can_crystallize = false if skill_level <= 3
    when .s?
      can_crystallize = false if skill_level <= 4
    end


    unless can_crystallize
      send_packet(SystemMessageId::CRYSTALLIZE_LEVEL_TOO_LOW)
      action_failed
      return
    end

    pc.in_crystallize = true

    if item.equipped?
      unequipped = inv.unequip_item_in_slot_and_record(item.location_slot)
      iu = InventoryUpdate.new
      unequipped.each { |it| iu.add_modified_item(it) }
      send_packet(iu)
      if item.enchant_level > 0
        sm = SystemMessage.equipment_s1_s2_removed
        sm.add_int(item.enchant_level)
      else
        sm = SystemMessage.s1_disarmed
      end
      sm.add_item_name(item)
      send_packet(sm)
    end

    removed_item = inv.destroy_item("Crystalize", @l2id, @count, pc, nil).not_nil!
    iu = InventoryUpdate.removed(removed_item)
    send_packet(iu)

    crystal_id = item.template.crystal_item_id
    crystal_amount = item.crystal_count.to_i64
    created_item = inv.add_item("Crystalize", crystal_id, crystal_amount, pc, pc).not_nil!

    sm = SystemMessage.s1_crystallized
    sm.add_item_name(removed_item)
    send_packet(sm)

    sm = SystemMessage.earned_s2_s1_s
    sm.add_item_name(created_item)
    sm.add_long(crystal_amount)
    send_packet(sm)

    pc.broadcast_user_info

    L2World.remove_object(removed_item)

    pc.in_crystallize = false
  end
end
