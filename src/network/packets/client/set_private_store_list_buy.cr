class Packets::Incoming::SetPrivateStoreListBuy < GameClientPacket
  BATCH_LENGTH = 40

  @items : Array(Item)?

  private def read_impl
    count = d
    if count < 1 || count > Config.max_item_in_packet || count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Array.new(count) do
      item_id = d
      d # L2J doesn't know what this is
      count = q
      price = q

      if item_id < 1 || count < 1 || price < 0
        return
      end

      d; d; d; d # unknown

      Item.new(item_id, count, price)
    end

    @items = items
  end

  private def run_impl
    return unless pc = active_char

    unless _items = @items
      pc.private_store_type = PrivateStoreType::NONE
      pc.broadcast_user_info
      return
    end

    unless pc.access_level.allow_transaction?
      send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    if AttackStances.includes?(pc) || pc.in_duel?
      send_packet(SystemMessageId::CANT_OPERATE_PRIVATE_STORE_DURING_COMBAT)
      send_packet(PrivateStoreManageListBuy.new(pc))
      action_failed
      return
    end

    if pc.inside_no_store_zone?
      send_packet(PrivateStoreManageListBuy.new(pc))
      send_packet(SystemMessageId::NO_PRIVATE_STORE_HERE)
      action_failed
      return
    end

    trade_list = pc.buy_list
    trade_list.clear

    if _items.size > pc.private_buy_store_limit
      send_packet(PrivateStoreManageListBuy.new(pc))
      send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_QUANTITY_THAT_CAN_BE_INPUTTED)
      return
    end

    total_cost = 0

    _items.each do |item|
      unless item.add_to_trade_list(trade_list)
        Util.punish(pc, "tried to set the price of a buy private store to more than #{Inventory.max_adena} adena.")
        return
      end

      total_cost += item.price
      if total_cost > Config.max_adena
        Util.punish(pc, "tried to set the total price of a buy private store to more than #{Inventory.max_adena} adena.")
        return
      end
    end

    if total_cost > pc.adena
      send_packet(PrivateStoreManageListBuy.new(pc))
      send_packet(SystemMessageId::THE_PURCHASE_PRICE_IS_HIGHER_THAN_MONEY)
      return
    end

    pc.sit_down
    pc.private_store_type = PrivateStoreType::BUY
    pc.broadcast_user_info
    pc.broadcast_packet(PrivateStoreMsgBuy.new(pc))
  end

  struct Item
    initializer item_id: Int32, count: Int64, price: Int64

    def add_to_trade_list(list : TradeList)
      if Config.max_adena / @count < @price
        false
      else
        list.add_item_by_item_id(@item_id, @count, @price)
        true
      end
    end

    def price : Int64
      @count * @price
    end
  end
end
