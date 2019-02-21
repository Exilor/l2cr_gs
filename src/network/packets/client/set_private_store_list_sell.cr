class Packets::Incoming::SetPrivateStoreListSell < GameClientPacket
  BATCH_LENGTH = 20

  @package_sale = false
  @items : Array(Item)?

  def read_impl
    @package_sale = d == 1
    count = d
    if count < 1 || count > Config.max_item_in_packet || count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Array.new(count) do
      item_id = d
      count = q
      price = q

      if item_id < 1 || count < 1 || price < 0
        return
      end

      Item.new(item_id, count, price)
    end

    @items = items
  end

  def run_impl
    return unless pc = active_char

    unless _items = @items
      send_packet(SystemMessageId::INCORRECT_ITEM_COUNT)
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
      send_packet(PrivateStoreManageListSell.new(pc, @package_sale))
      action_failed
      return
    end

    if pc.inside_no_store_zone?
      send_packet(PrivateStoreManageListSell.new(pc, @package_sale))
      send_packet(SystemMessageId::NO_PRIVATE_STORE_HERE)
      action_failed
      return
    end

    if _items.size > pc.private_sell_store_limit
      send_packet(PrivateStoreManageListSell.new(pc, @package_sale))
      send_packet(SystemMessageId::YOU_HAVE_EXCEEDED_QUANTITY_THAT_CAN_BE_INPUTTED)
      return
    end

    trade_list = pc.sell_list
    trade_list.clear
    trade_list.packaged = @package_sale

    total_cost = 0

    _items.each do |item|
      unless item.add_to_trade_list(trade_list)
        Util.punish(pc, "tried to set the price of a sell private store at more than #{Inventory.max_adena} adena.")
        return
      end

      total_cost += item.price
      if total_cost > Config.max_adena
        Util.punish(pc, "tried to set the total price of a sell private store at more than #{Inventory.max_adena} adena.")
        return
      end
    end

    pc.sit_down
    if @package_sale
      pc.private_store_type = PrivateStoreType::PACKAGE_SELL
    else
      pc.private_store_type = PrivateStoreType::SELL
    end
    pc.broadcast_user_info
    if @package_sale
      pc.broadcast_packet(ExPrivateStoreSetWholeMsg.new(pc))
    else
      pc.broadcast_packet(PrivateStoreMsgSell.new(pc))
    end
  end

  struct Item
    initializer item_id: Int32, count: Int64, price: Int64

    def add_to_trade_list(list : TradeList) : Bool
      if Config.max_adena / @count < @price
        return false
      end

      list.add_item(@item_id, @count, @price)
      true
    end

    def price : Int64
      @count * @price
    end
  end
end
