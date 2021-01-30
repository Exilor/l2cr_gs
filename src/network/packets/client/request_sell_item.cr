require "../../../models/holders/unique_item_holder"

class Packets::Incoming::RequestSellItem < GameClientPacket
  BATCH_LENGTH = 16

  @list_id = 0
  @items : Array(UniqueItemHolder)?

  private def read_impl
    @list_id = d
    size = d
    if size <= 0 || size * BATCH_LENGTH != buffer.remaining
      return
    end
    items = Array(UniqueItemHolder).new(size)

    size.times do
      l2id, item_id, count = d, d, q
      if l2id < 1 || item_id < 1 || count < 1
        items.clear
        break
      else
        items << UniqueItemHolder.new(item_id, l2id, count)
      end
    end

    @items = items
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("buy")
      pc.send_message("You are buying too fast.")
      return
    end

    return unless _items = @items

    if _items.empty?
      debug "Empty item selection."
      action_failed
      return
    end

    if !Config.alt_game_karma_player_can_shop && pc.karma > 0
      action_failed
      return
    end

    unless merchant = pc.target.as?(L2MerchantInstance)
      debug "Target is not a L2MerchantInstance."
      action_failed
      return
    end

    unless buy_list = BuyListData.get_buy_list(@list_id)
      Util.punish(pc, "sent an invalid BuyList list_id #{@list_id}.")
      return
    end

    unless buy_list.npc_allowed?(merchant.id)
      debug { "Merchant #{merchant.id} is not allowed in buylist #{@list_id}." }
      action_failed
      return
    end

    total_price = 0i64

    _items.each do |i|
      unless item = pc.check_item_manipulation(i.l2id, i.count, "sell")
        warn "#check_item_manipulation failed."
        next
      end

      next unless item.sellable?

      price = item.reference_price // 2
      total_price += price * i.count

      if Inventory.max_adena // i.count < price || total_price > Inventory.max_adena
        Util.punish(pc, "tried to sell over #{Inventory.max_adena} adena worth of items.")
        return
      end

      if Config.allow_refund
        pc.inventory.transfer_item("Sell", i.l2id, i.count, pc.refund, pc, merchant)
      else
        pc.inventory.destroy_item("Sell", i.l2id, i.count, pc, merchant)
      end
    end

    pc.add_adena("Sell", total_price, merchant, false)

    send_packet(StatusUpdate.current_load(pc))
    send_packet(ExBuySellList.new(pc, true))
  end
end
