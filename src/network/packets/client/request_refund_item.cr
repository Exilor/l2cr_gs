class Packets::Incoming::RequestRefundItem < GameClientPacket
  BATCH_LENGTH = 4

  @list_id = 0
  @items : Slice(Int32)?

  private def read_impl
    @list_id = d
    count = d
    if count <= 0 || count > Config.max_item_in_packet || count * BATCH_LENGTH != buffer.remaining
      warn "Size of packet doesn't match expected size of its item list."
      return
    end
    @items = Slice.new(count) { d }
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("refund")
      pc.send_message("You are using refund too fast.")
      return
    end

    unless items = @items
      action_failed
      return
    end

    unless pc.has_refund?
      debug { "#{pc.name} doesn't have a refund." }
      action_failed
      return
    end

    unless merchant = pc.target
      action_failed
      return
    end

    if !pc.gm? && (!merchant.is_a?(L2MerchantInstance) || (pc.instance_id != merchant.instance_id) || !pc.inside_radius?(merchant, L2Npc::INTERACTION_DISTANCE, true, false))
      action_failed
      return
    end

    unless buy_list = BuyListData.get_buy_list(@list_id)
      Util.punish(pc, "sent an invalid BuyList list_id #{@list_id}.")
      warn { "No buy list with ID #{@list_id}." }
      return
    end

    unless buy_list.npc_allowed?(merchant.id)
      warn { "#{merchant} is not allowed to use buy list with id #{@list_id}." }
      action_failed
      return
    end

    weight = slots = 0
    adena = 0i64

    refund = pc.refund.items
    l2ids = Slice.new(items.size, 0)

    inv = pc.inventory

    items.each_with_index do |idx, i|
      if idx < 0 || idx >= refund.size
        warn { "Refund index error #{idx}/#{refund.size}." }
        Util.punish(pc, "sent an invalid refund index.")
        return
      end

      (i &+ 1...items.size).each do |j|
        if idx == items[j]
          warn { "Duplicated refund index #{idx}, #{items[j]}." }
          Util.punish(pc, "sent a duplicate refund index.")
          return
        end
      end

      item = refund[idx]
      template = item.template
      l2ids[i] = item.l2id

      i.times do |j|
        if l2ids[i] == l2ids[j]
          warn { "Duplicated refund l2id #{l2ids[i]}, #{l2ids[j]}." }
          Util.punish(pc, "sent a duplicate refund index.")
          return
        end
      end

      count = item.count
      weight += count * template.weight
      adena += (count * template.reference_price) // 2

      if !template.stackable?
        slots += count
      elsif inv.get_item_by_item_id(template.id).nil?
        slots += 1
      end
    end

    if weight > Int32::MAX || weight < 0 || !inv.validate_weight(weight)
      pc.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
      action_failed
      return
    end

    if slots > Int32::MAX || weight < 0 || !inv.validate_capacity(slots)
      pc.send_packet(SystemMessageId::SLOTS_FULL)
      action_failed
      return
    end

    if adena < 0 || !pc.reduce_adena("Refund", adena, pc.last_folk_npc, false)
      pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      action_failed
      return
    end

    items.each_index do |i|
      item = pc.refund.transfer_item(
        "Refund",
        l2ids[i],
        Int64::MAX,
        inv,
        pc,
        pc.last_folk_npc
      )

      unless item
        warn { "Error refunding item for player #{pc.name} (new item is nil)." }
        next
      end
    end

    pc.send_packet(StatusUpdate.current_load(pc))
    pc.send_packet(ExBuySellList.new(pc, true))
  end
end
