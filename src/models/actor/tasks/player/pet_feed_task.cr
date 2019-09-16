struct PetFeedTask
  initializer pc: L2PcInstance

  def call
    if @pc.mounted? || @pc.mount_npc_id == 0 || PetDataTable.get_pet_data(@pc.mount_npc_id).nil?
      @pc.stop_feed
      return
    end

    if @pc.current_feed > @pc.feed_consume
      @pc.current_feed -= @pc.feed_consume
    else
      @pc.current_feed = 0
      @pc.stop_feed
      @pc.dismount
      @pc.send_packet(SystemMessageId::OUT_OF_FEED_MOUNT_CANCELED)
      return
    end

    food_ids = PetDataTable.get_pet_data(@pc.mount_npc_id).not_nil!.food
    return if food_ids.empty?

    food = nil
    food_ids.each do |id|
      if food = @pc.inventory.get_item_by_item_id(id)
        break
      end
    end

    if food && @pc.hungry?
      if handler = ItemHandler[food.etc_item]
        handler.use_item(@pc, food, false)
        sm = Packets::Outgoing::SystemMessage.pet_took_s1_because_he_was_hungry
        sm.add_item_name(food.id)
        @pc.send_packet(sm)
      end
    end
  end
end
