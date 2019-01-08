require "../../../models/item_request"

class Packets::Incoming::RequestPrivateStoreBuy < GameClientPacket
  no_action_request

  BATCH_LENGTH = 20

  @store_player_id = 0
  @items : Set(ItemRequest)?

  def read_impl
    @store_player_id = d
    count = d

    if count <= 0 || count > Config.max_item_in_packet || count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Set(ItemRequest).new
    count.times do |i|
      l2id = d
      count = q
      price = q

      if l2id < 1 || count < 1 || price < 0
        @items = nil
        return
      end

      items << ItemRequest.new(l2id, count, price)
    end

    @items = items
  end

  def run_impl
    return unless pc = active_char
    unless _items = @items
      action_failed
      return
    end

    unless flood_protectors.transaction.try_perform_action("privatestorebuy")
      pc.send_message("You are buying items too fast.")
      return
    end

    unless store_player = L2World.get_player(@store_player_id)
      warn "Player with ID #{@store_player_id} not found."
      return
    end

    return if pc.cursed_weapon_equipped?

    unless pc.inside_radius?(store_player, L2Npc::INTERACTION_DISTANCE, true, false)
      return
    end

    if pc.instance_id != store_player.instance_id && pc.instance_id != -1
      return
    end

    unless store_player.private_store_type.sell? || store_player.private_store_type.package_sell?
      return
    end

    unless store_list = store_player.sell_list
      return
    end

    unless pc.access_level.allow_transaction?
      pc.send_message("Transactions are disabled for your Access Level.")
      action_failed
      return
    end

    if store_player.private_store_type.package_sell?
      if store_list.item_count > _items.size
        Util.punish(pc, "tried to buy less items than established by the package sale.")
        return
      end
    end

    result = store_list.private_store_buy(pc, _items)
    if result > 0
      action_failed
      if result > 1
        warn "Private store buy has failed due to invalid list or request. Player: #{pc.name}, store owner: #{store_player.name}."
      end
      return
    end

    if store_list.item_count == 0
      store_player.private_store_type = PrivateStoreType::NONE
      store_player.broadcast_user_info
    end
  end
end
