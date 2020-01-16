class Packets::Incoming::RequestSetCrop < GameClientPacket
  private BATCH_LENGTH = 21

  @manor_id = 0
  @items = [] of CropProcure

  private def read_impl
    @manor_id = d

    count = d
    if count <= 0 || count > Config.max_item_in_packet
      return
    end

    if count * BATCH_LENGTH != buffer.remaining
      return
    end

    count.times do
      item_id = d
      sales = q
      price = q
      type = c
      if item_id < 1 || sales < 0 || price < 0
        return
      end

      if sales > 0
        @items << CropProcure.new(item_id, sales, type, sales, price)
      end
    end
  end

  private def run_impl
    return unless pc = active_char
    return if @items.empty?
    clan = pc.clan
    if !CastleManorManager.modifiable_period? || (clan.nil? || clan.castle_id != @manor_id) || !pc.has_clan_privilege?(ClanPrivilege::CS_MANOR_ADMIN) || !pc.last_folk_npc.not_nil!.can_interact?(pc)
      action_failed
      return
    end

    @items.select! do |cp|
      next unless s = CastleManorManager.get_seed_by_crop(cp.id, @manor_id)
      cp.start_amount <= s.crop_limit &&
      cp.price.between?(s.crop_min_price, s.crop_max_price)
    end

    CastleManorManager.set_next_crop_procure(@items, @manor_id)
  end
end
