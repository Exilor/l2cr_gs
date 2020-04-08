class Packets::Incoming::RequestPreviewItem < GameClientPacket
  private struct RemoveWearItemsTask
    initializer pc : L2PcInstance

    def call
      @pc.send_packet(SystemMessageId::NO_LONGER_TRYING_ON)
      @pc.send_packet(Packets::Outgoing::UserInfo.new(@pc))
    end
  end

  @list_id = 0
  @count = 0
  @items = Slice(Int32).empty

  private def read_impl
    unk = d
    @list_id = d
    @count = d

    unless @count.between?(0, 100)
      return
    end

    @items = Slice.new(@count) { d }
  end

  private def run_impl
    return unless pc = active_char
    return if @items.empty?

    unless flood_protectors.transaction.try_perform_action("buy")
      pc.send_message("You are buying too fast.")
      return
    end

    if !Config.alt_game_karma_player_can_shop && pc.karma > 0
      return
    end

    target = pc.target

    if !pc.gm? && (!target.is_a?(L2MerchantInstance) || !pc.inside_radius?(target, L2Npc::INTERACTION_DISTANCE, false, false))
      return
    end

    if @count < 1 || @list_id >= 4_000_000
      action_failed
      return
    end

    unless merchant = target.as?(L2MerchantInstance)
      warn { "Target (#{target}) is not a L2MerchantInstance." }
      return
    end

    unless buy_list = BuyListData.get_buy_list(@list_id)
      Util.punish(pc, "sent an invalid BuyList list_id #{@list_id}.")
      warn { "Buy list with id #{@list_id} not found." }
      return
    end

    total_price = 0i64
    item_list = {} of Int32 => Int32

    @count.times do |i|
      item_id = @items[i]
      unless product = buy_list.get_product_by_item_id(item_id)
        Util.punish(pc, "sent an invalid BuyList list_id #{@list_id}, item_id #{item_id}.")
        return
      end

      unless template = product.item
        warn { "Missing template for product #{product}." }
        next
      end

      slot = Inventory.get_paperdoll_index(template.body_part)
      if slot < 0
        warn { "Wrong paperdoll slot #{slot}. Body part: #{template.body_part}." }
        next
      end

      case template
      when L2Weapon
        if pc.race.kamael?
          type = template.item_type
          if type.none?
            next
          elsif type.rapier? || type.crossbow? || type.ancientsword?
            next
          end
        end
      when L2Armor
        if pc.race.kamael?
          type = template.item_type
          if type.heavy? || type.magic?
            next
          end
        end
      else
        # automatically added
      end


      if item_list.has_key?(slot)
        pc.send_packet(SystemMessageId::YOU_CAN_NOT_TRY_THOSE_ITEMS_ON_AT_THE_SAME_TIME)
        return
      end

      item_list[slot] = item_id
      total_price += Config.wear_price

      if total_price > Inventory.max_adena
        Util.punish(pc, "tried to purchase over #{Inventory.max_adena} adena worth of items.")
        return
      end
    end

    if total_price < 0 || !pc.reduce_adena("Wear", total_price, pc.last_folk_npc, true)
      pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
      return
    end

    unless item_list.empty?
      pc.send_packet(ShopPreviewInfo.new(item_list))
      task = RemoveWearItemsTask.new(pc)
      ThreadPoolManager.schedule_general(task, Config.wear_delay * 1000)
    end
  end
end