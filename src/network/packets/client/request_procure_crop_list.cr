require "../../../models/holders/unique_item_holder"

class Packets::Incoming::RequestProcureCropList < GameClientPacket
  private BATCH_LENGTH = 20

  @items : Slice(CropHolder) = Slice(CropHolder).empty

  private def read_impl
    count = d

    if count <= 0 || count > Config.max_item_in_packet
      return
    end

    if count * BATCH_LENGTH != buffer.remaining
      return
    end

    items = Slice.new(count) do
      l2id = d
      item_id = d
      manor_id = d
      cnt = q
      if l2id < 1 || item_id < 1 || manor_id < 0 || cnt < 0
        return
      end

      CropHolder.new(l2id, item_id, cnt, manor_id)
    end

    @items = items
  end

  private def run_impl
    return unless pc = active_char
    return if @items.empty?

    if CastleManorManager.under_maintenance?
      action_failed
      return
    end

    manager = pc.last_folk_npc

    if !manager.is_a?(L2MerchantInstance) || !manager.can_interact?(pc)
      action_failed
      return
    end

    castle_id = manager.castle.residence_id
    if manager.template.parameters.get_i32("manor_id", -1) != castle_id
      action_failed
      return
    end

    slots = weight = 0

    @items.each do |i|
      item = pc.inventory.get_item_by_l2id(i.l2id)
      if item.nil? || (item.count < i.count || item.id != i.id)
        action_failed
        return
      end

      cp = i.crop_procure
      if cp.nil? || cp.amount < i.count
        action_failed
        return
      end

      template = ItemTable[i.reward_id]
      weight += i.count * template.weight

      if !template.stackable?
        slots += i.count
      elsif pc.inventory.get_item_by_item_id(i.reward_id).nil?
        slots += 1
      end
    end

    if !pc.inventory.validate_weight(weight)
      pc.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
      return
    elsif !pc.inventory.validate_capacity(slots)
      pc.send_packet(SystemMessageId::SLOTS_FULL)
      return
    end

    update_list_size = Config.alt_manor_save_all_actions ? @items.size : 0
    update_list = Array(CropProcure).new(update_list_size)

    @items.each do |i|
      reward_price = ItemTable[i.reward_id].reference_price
      if reward_price == 0
        next
      end

      reward_item_count = i.price // reward_price
      if reward_item_count < 1
        sm = SystemMessage.failed_in_trading_s2_of_crop_s1
        sm.add_item_name(i.id)
        sm.add_long(i.count)
        pc.send_packet(sm)
        next
      end

      fee = castle_id == i.manor_id ? 0 : (i.price * 0.05).to_i64
      if fee != 0 && pc.adena < fee
        sm = SystemMessage.failed_in_trading_s2_of_crop_s1
        sm.add_item_name(i.id)
        sm.add_long(i.count)
        pc.send_packet(sm)

        sm = SystemMessage.you_not_enough_adena
        pc.send_packet(sm)
        next
      end

      cp = i.crop_procure.not_nil!
      if !cp.decrease_amount(i.count) || (fee > 0 && !pc.reduce_adena("Manor", fee, manager, true)) || !pc.destroy_item("Manor", i.l2id, i.count, manager, true)
        next
      end

      pc.add_item("Manor", i.reward_id, reward_item_count, manager, true)

      if Config.alt_manor_save_all_actions
        update_list << cp
      end
    end

    if Config.alt_manor_save_all_actions
      CastleManorManager.update_current_procure(castle_id, update_list)
    end
  end

  private class CropHolder < UniqueItemHolder
    @reward_id = 0

    getter manor_id
    private getter! cp : CropProcure

    def initialize(l2id : Int32, id : Int32, count : Int64, manor_id : Int32)
      super(id, l2id, count)
      @manor_id = manor_id
    end

    def price : Int64
      count * cp.price
    end

    def crop_procure : CropProcure?
      @cp ||= CastleManorManager.get_crop_procure(@manor_id, id, false)
    end

    def reward_id : Int32
      if @reward_id == 0
        @reward_id = CastleManorManager.get_seed_by_crop(cp.id).not_nil!.get_reward(cp.reward)
      end

      @reward_id
    end
  end
end
