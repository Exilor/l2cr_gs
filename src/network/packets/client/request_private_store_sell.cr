class Packets::Incoming::RequestPrivateStoreSell < GameClientPacket
  no_action_request

  BATCH_LENGTH = 28

  @store_player_id = 0
  @items : Array(ItemRequest)?

  def read_impl
    @store_player_id = d
    count = d

    if count <= 0 || count > Config.max_item_in_packet || count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = [] of ItemRequest
    count.times do |i|
      l2id = d
      item_id = d
      h; h # L2J doesn't know what this is
      count = q
      price = q

      if l2id < 1 || item_id < 1 || count < 1 || price < 0
        return
      end

      items << ItemRequest.new(l2id, item_id, count, price)
    end

    @items = items
  end

  def run_impl
    return unless pc = active_char

    unless _items = @items
      action_failed
      return
    end

    unless flood_protectors.transaction.try_perform_action("privatestoresell")
      pc.send_message("You are selling items too fast.")
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

    unless store_player.private_store_type.buy?
      return
    end

    unless store_list = store_player.buy_list
      return
    end

    unless pc.access_level.allow_transaction?
      pc.send_message("Transactions are disabled for your Access Level.")
      action_failed
      return
    end

    unless store_list.private_store_sell(pc, _items)
      action_failed
      warn "Private store sell has failed due to invalid list or request. Player: #{pc.name}, store owner: #{store_player.name}."
      return
    end

    if store_list.item_count == 0
      store_player.private_store_type = PrivateStoreType::NONE
      store_player.broadcast_user_info
    end
  end
end
