class Packets::Incoming::RequestWithDrawPremiumItem < GameClientPacket
  @item_num = 0
  @char_id = 0
  @item_count = 0i64

  private def read_impl
    @item_num = d
    @char_id = d
    @item_count = q
  end

  private def run_impl
    return unless pc = active_char
    return unless @item_count > 0

    unless pc.l2id == @char_id
      Util.punish(pc, "sent incorrect owner id for RequestWithDrawPremiumItem.")
      return
    end

    if pc.premium_item_list.empty?
      Util.punish(pc, "tried to get a premium item while having an empty premium item list.")
      return
    end

    if pc.weight_penalty >= 3 || !pc.inventory_under_90?(false)
      pc.send_packet(SystemMessageId::YOU_CANNOT_RECEIVE_THE_VITAMIN_ITEM)
      return
    end

    if pc.processing_transaction?
      pc.send_packet(SystemMessageId::YOU_CANNOT_RECEIVE_A_VITAMIN_ITEM_DURING_AN_EXCHANGE)
      return
    end

    unless item = pc.premium_item_list[@item_num]?
      return
    end

    if item.count < @item_count
      return
    end

    items_left = item.count - @item_count

    pc.add_item("PremiumItem", item.item_id, @item_count, pc.target, true)

    if items_left > 0
      item.update_count(items_left)
      GameDB.premium_item.update(pc, @item_num, items_left)
    else
      pc.premium_item_list.delete(@item_num)
      GameDB.premium_item.delete(pc, @item_num)
    end

    if pc.premium_item_list.empty?
      pc.send_packet(SystemMessageId::THERE_ARE_NO_MORE_VITAMIN_ITEMS_TO_BE_FOUND)
    else
      pc.send_packet(ExGetPremiumItemList.new(pc))
    end
  end
end
