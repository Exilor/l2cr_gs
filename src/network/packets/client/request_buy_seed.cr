class Packets::Incoming::RequestBuySeed < GameClientPacket
  private BATCH_LENGTH = 12

  @items : Slice(ItemHolder)?
  @manor_id = 0

  private def read_impl
    @manor_id = d

    count = d

    if count <= 0 || count > Config.max_item_in_packet || count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Slice.new(count) do |i|
      item_id = d
      cnt = q
      if cnt < 1 || item_id < 1
        return
      end

      ItemHolder.new(item_id, cnt)
    end

    @items = items
  end

  private def run_impl
    return unless pc = active_char

    unless _items = @items
      action_failed
      return
    end

    unless flood_protectors.manor.try_perform_action("BuySeed")
      pc.send_message("You are buying seeds too fast.")
      return
    end

    manor = CastleManorManager

    if manor.under_maintenance?
      action_failed
      return
    end

    unless castle = CastleManager.get_castle_by_id(@manor_id)
      action_failed
      return
    end

    manager = pc.last_folk_npc

    unless manager.is_a?(L2MerchantInstance)
      action_failed
      return
    end

    if !manager.can_interact?(pc)
      action_failed
      return
    end

    if manager.template.parameters.get_i32("manor_id", -1) != @manor_id
      warn { "#{manager}'s parameters don't match the requested manor id." }
      warn { "Manager parameters: #{manager.template.parameters}, manor id: #{@manor_id}." }
      action_failed
      return
    end

    total_price = 0i64
    slots = 0
    total_weight = 0

    product_info = {} of Int32 => SeedProduction

    _items.each do |ih|
      unless sp = manor.get_seed_product(@manor_id, ih.id, false)
        action_failed
        return
      end

      if sp.price <= 0 || sp.amount < ih.count
        action_failed
        return
      end

      if Inventory.max_adena / ih.count < sp.price
        action_failed
        return
      end

      total_price += sp.price * ih.count

      if total_price > Inventory.max_adena
        Util.punish(pc, "tried to purchase over #{Inventory.max_adena} adena worth of seeds.")
        action_failed
        return
      end

      template = ItemTable[ih.id]
      total_weight += ih.count * template.weight

      if !template.stackable?
        slots += ih.count
      elsif pc.inventory.get_item_by_item_id(ih.id).nil?
        slots += 1
      end

      product_info[ih.id] = sp
    end

    if !pc.inventory.validate_weight(total_weight)
      pc.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
      return
    elsif !pc.inventory.validate_capacity(slots)
      pc.send_packet(SystemMessageId::SLOTS_FULL)
      return
    elsif total_price < 0 || pc.adena < total_price
      pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      return
    end

    _items.each do |i|
      sp = product_info[i.id]
      price = sp.price * i.count

      if !sp.decrease_amount(i.count) || !pc.reduce_adena("Buy", price, pc, false)
        total_price -= price
        next
      end

      pc.add_item("Buy", i.id, i.count, manager, true)
    end

    if total_price > 0
      castle.add_to_treasury_no_tax(total_price)

      sm = SystemMessage.s1_disappeared_adena
      sm.add_long(total_price)
      pc.send_packet(sm)

      if Config.alt_manor_save_all_actions
        manor.update_current_production(@manor_id, product_info.local_each_value)
      end
    end
  end
end
