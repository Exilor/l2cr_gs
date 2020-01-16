class Packets::Incoming::RequestBuyItem < GameClientPacket
  BATCH_LENGTH = 12

  @items = [] of ItemHolder
  @list_id = 0

  private def read_impl
    @list_id = d
    size = d

    if size <= 0 || size * BATCH_LENGTH != buffer.remaining
      warn { "Invalid size of item list: #{size}. Remaining data in buffer: #{buffer.remaining} bytes." }
      return
    end

    size.times do
      item_id = d
      count = q
      if item_id < 1 || count < 1
        @items.clear
        return
      end
      @items << ItemHolder.new(item_id, count)
    end
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("buy")
      pc.send_message("You are buying too fast.")
      return
    end

    if @items.empty?
      action_failed
      return
    end

    if !Config.alt_game_karma_player_can_shop && pc.karma > 0
      action_failed
      return
    end

    unless pc.gm?
      unless target = pc.target
        action_failed
        return
      end

      if !pc.inside_radius?(target, L2Npc::INTERACTION_DISTANCE, true, false) || pc.instance_id != target.instance_id
        action_failed
        return
      end

      unless merchant = target.as?(L2Character)
        action_failed
        return
      end
    end

    castle_tax_rate = base_tax_rate = 0.0

    unless buy_list = BuyListData.get_buy_list(@list_id)
      Util.punish(pc, "sent an invalid BuyList list_id #{@list_id}.")
      return
    end

    if merchant
      unless buy_list.npc_allowed?(merchant.id)
        action_failed
        return
      end

      if merchant.is_a?(L2MerchantInstance)
        castle_tax_rate = merchant.mpc.castle_tax_rate
        base_tax_rate = merchant.mpc.base_tax_rate
      else
        base_tax_rate = 0.5
      end
    end

    sub_total = slots = weight = 0

    @items.each do |i|
      unless product = buy_list.get_product_by_item_id(i.id)
        warn { "No product with ID #{i.id} in BuyList #{buy_list}." }
        Util.punish(pc, "sent an invalid BuyList list_id #{@list_id} and item_id #{i.id}")
        return
      end

      if !product.item.stackable? && i.count > 1
        Util.punish(pc, "tried to purchase an invalid quantity of items at the same time.")
        send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_QUANTITY_THAT_CAN_BE_INPUTTED)
        return
      end

      price = product.price
      debug { "Buying #{product.item.name} which costs #{product.price} adena." }

      if product.item_id.between?(3960, 4026)
        price *= Config.rate_siege_guards_price
      end

      if price < 0
        error { "Negative price for #{product}." }
        action_failed
        return
      end

      if price == 0 && !pc.gm? && Config.only_gm_items_free
        warn { "#{pc} tried to buy a item for 0 adena." }
        Util.punish(pc, "tried to buy an item for 0 adena.")
        return
      end

      if product.limited_stock?
        if i.count > product.count
          action_failed
          return
        end
      end

      if Inventory.max_adena / i.count < price
        Util.punish(pc, "tried to buy over #{Inventory.max_adena} worth of items.")
        return
      end

      price *= 1 + castle_tax_rate + base_tax_rate
      sub_total += i.count * price

      if sub_total > Inventory.max_adena
        Util.punish(pc, "tried to buy over #{Inventory.max_adena} worth of items.")
        return
      end

      weight += i.count * product.item.weight

      unless pc.inventory.get_item_by_item_id(product.item_id)
        slots += 1
      end
    end

    if !pc.gm? && (weight > Int32::MAX || weight < 0 || !pc.inventory.validate_weight(weight))
      pc.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
      action_failed
      return
    end

    if !pc.gm? && (slots > Int32::MAX || slots < 0 || !pc.inventory.validate_capacity(slots))
      pc.send_packet(SystemMessageId::SLOTS_FULL)
      action_failed
      return
    end

    if sub_total < 0 || !pc.reduce_adena("Buy", sub_total.to_i64, pc.last_folk_npc, false)
      debug { "Not enough adena (subtotal: #{sub_total})." }
      pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      action_failed
      return
    end

    @items.each do |i|
      unless product = buy_list.get_product_by_item_id(i.id)
        Util.punish(pc, "sent an invalid BuyList list_id #{@list_id} and item_id #{i.id}")
        next
      end
      if product.limited_stock?
        debug { "#{i} has limited stock." }
        if product.decrease_count(i.count)
          pc.inventory.add_item("Buy", i.id, i.count, pc, merchant)
        else
          debug "Failed to decrease the count of an item with limited stock."
        end
      else
        pc.inventory.add_item("Buy", i.id, i.count, pc, merchant)
      end
    end

    if merchant.is_a?(L2MerchantInstance)
      total = (sub_total * castle_tax_rate).to_i64
      merchant.castle.add_to_treasury(total)
    end

    send_packet(StatusUpdate.current_load(pc))
    send_packet(ExBuySellList.new(pc, true))
  end
end
