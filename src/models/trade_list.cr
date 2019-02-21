class TradeList
  include Loggable
  include Synchronizable
  include Packets::Outgoing

  getter items = Array(TradeItem).new
  property title : String = ""
  property! partner : L2PcInstance?
  property? locked = false
  property? packaged = false
  property? confirmed = false

  getter_initializer owner: L2PcInstance

  def get_available_items(inv : PcInventory) : Array(TradeItem)
    @items.map do |item|
      item = TradeItem.new(item, item.count, item.price)
      inv.adjust_available_item(item)
      item
    end
  end

  def item_count : Int32
    @items.size
  end

  def adjust_available_item(item : L2ItemInstance) : TradeItem?
    if item.stackable?
      @items.each do |it|
        if it.item.id == item.id
          return if item.count <= it.count
          return TradeItem.new(item, item.count - it.count, item.reference_price.to_i64)
        end
      end
    end

    TradeItem.new(item, item.count, item.reference_price.to_i64)
  end

  def adjust_item_request(item : ItemRequest)
    @items.each do |it|
      if it.l2id == item.l2id
        if it.count < item.count
          item.count = it.count
        end
        return
      end
    end

    item.count = 0
  end

  def add_item(id : Int32, count : Int64, price : Int64 = 0i64) : TradeItem?
    sync do
      if locked?
        warn "#{@owner} attempted to modify a locked TradeList."
        return
      end

      obj = L2World.find_object(id)

      unless obj.is_a?(L2ItemInstance)
        warn "#{@owner} attempted to add a #{obj.class}."
        return
      end

      item = obj # as L2ItemInstance

      if !item.tradeable? || !(item.tradeable? || @owner.gm? && Config.gm_trade_restricted_items) || item.quest_item?
        warn "#{@owner} attempted to add a restricted item: #{item}."
        return
      end

      unless @owner.inventory.can_manipulate_with_item_id?(item.id)
        warn "#{@owner} attempted to add an item that he can't manipulate: #{item}."
        return
      end

      if count <= 0 || count > item.count
        warn "#{@owner} attempted to add an item with invalid count: #{count}"
        return
      end

      if !item.stackable? && count > 1
        warn "#{@owner} attempted to add multiple non-stackable items at once: #{item} x#{count}."
        return
      end

      if Inventory.max_adena / count < price
        warn "#{@owner} attempted to overflow adena."
        return
      end

      @items.each do |it|
        if it.l2id == id
          debug "#{@owner} attempted to add an item already listed: #{it}."
          return
        end
      end

      t_item = TradeItem.new(item, count, price)
      @items << t_item
      invalidate_confirmation
      t_item
    end
  end

  def add_item_by_item_id(id : Int32, count : Int64, price : Int64) : TradeItem?
    sync do
      if locked?
        warn "#{@owner} attempted to modify a locked TradeList."
        return
      end

      item = ItemTable[id]

      unless item
        warn "#{@owner} attempted to add an item with unknown ID #{id}."
        return
      end

      return if !item.tradeable? || item.quest_item?

      if !item.stackable? && count > 1
        warn "#{@owner} attempted to add multiple non-stackable items at once: #{item} x#{count}."
        return
      end

      if Inventory.max_adena / count < price
        warn "#{@owner} attempted to overflow adena."
        return
      end

      t_item = TradeItem.new(item, count, price)
      @items << t_item
      invalidate_confirmation
      t_item
    end
  end

  def remove_item(l2id : Int32, item_id : Int32, count : Int64) : TradeItem?
    sync do
      if locked?
        warn "#{@owner} attempted to modify a locked TradeList."
        return
      end

      @items.each do |item|
        if item.l2id == l2id || item.item.id == item_id
          if partner = @partner
            unless partner_list = partner.active_trade_list
              warn "#{partner} has no active trade list."
              return
            end
            partner_list.invalidate_confirmation
          end

          if count != -1 && item.count > count
            item.count = item.count - count
          else
            @items.delete_first(item)
          end
          return item
        end
      end

      nil
    end
  end

  def update_items
    sync do
      @items.each do |it|
        item = @owner.inventory.get_item_by_l2id(it.l2id)

        if item.nil? || it.count < 1
          remove_item(it.l2id, -1, -1)
        elsif item.count < it.count
          it.count = item.count
        end
      end
    end
  end

  def lock
    @locked = true
  end

  def clear
    sync do
      @items.clear
      @locked = false
    end
  end

  def confirm : Bool
    return true if @confirmed

    if partner = @partner
      unless partner_list = partner.active_trade_list
        warn "#{partner} has no active trade list."
        return false
      end

      if @owner.l2id > partner_list.owner.l2id
        sync_1 , sync_2 = partner_list, self
      else
        sync_1, sync_2 = self, partner_list
      end

      sync_1.sync do
        sync_2.sync do
          @confirmed = true
          if partner_list.confirmed?
            partner_list.lock
            lock
            return false unless partner_list.validate
            return false unless validate
            do_exchange(partner_list)
          else
            partner.on_trade_confirm(@owner)
          end
        end
      end
    else
      @confirmed = true
    end

    @confirmed
  end

  def invalidate_confirmation
    @confirmed = false
  end

  def validate : Bool
    unless L2World.get_player(@owner.l2id)
      warn "Invalid owner of TradeList."
      return false
    end

    @items.each do |it|
      item = @owner.check_item_manipulation(it.l2id, it.count, "transfer")
      if !item || item.count < 1
        warn "Invalid item in TradeList: #{it}."
        return false
      end
    end

    true
  end

  protected def transfer_items(partner : L2PcInstance, owner_iu : InventoryUpdate?, partner_iu : InventoryUpdate?) : Bool
    @items.each do |it|
      old_item = @owner.inventory.get_item_by_l2id(it.l2id)
      return false unless old_item
      new_item = @owner.inventory.transfer_item("Trade", it.l2id, it.count, partner.inventory, @owner, @partner)
      return false unless new_item

      if owner_iu
        if old_item.count > 0 && old_item != new_item
          owner_iu.add_modified_item(old_item)
        else
          owner_iu.add_removed_item(old_item)
        end
      end

      if partner_iu
        if new_item.count > it.count
          partner_iu.add_modified_item(new_item)
        else
          partner_iu.add_new_item(new_item)
        end
      end
    end

    true
  end

  def count_item_slots(partner : L2PcInstance) : Int32
    slots = 0
    @items.each do |item|
      template = ItemTable[item.item.id]?
      next unless template
      if !template.stackable?
        slots += item.count
      elsif !partner.inventory.get_item_by_item_id(item.item.id)
        slots += 1
      end
    end

    slots
  end

  def calc_items_weight : Int32
    weight = 0
    @items.each do |item|
      template = ItemTable[item.item.id]?
      next unless template
      weight += item.count * template.weight
    end

    Math.min(weight, Int32::MAX)
  end

  private def do_exchange(partner_list : TradeList)
    success = false

    if !@owner.inventory.validate_weight(partner_list.calc_items_weight) || !partner_list.owner.inventory.validate_weight(calc_items_weight)
      partner_list.owner.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
      @owner.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
    elsif !@owner.inventory.validate_capacity(partner_list.count_item_slots(@owner)) || !partner_list.owner.inventory.validate_capacity(count_item_slots(partner_list.owner))
      partner_list.owner.send_packet(SystemMessageId::SLOTS_FULL)
      @owner.send_packet(SystemMessageId::SLOTS_FULL)
    else
      owner_iu = InventoryUpdate.new
      partner_iu = InventoryUpdate.new

      partner_list.transfer_items(@owner, partner_iu, owner_iu)
      transfer_items(partner_list.owner, owner_iu, partner_iu)

      partner = partner_list.owner
      if owner_iu
        @owner.send_packet(owner_iu)
      else
        @owner.send_packet(ItemList.new(@owner, false))
      end

      if partner_iu
        partner.send_packet(partner_iu)
      else
        partner.send_packet(partner_iu)
      end

      @owner.send_packet(StatusUpdate.current_load(@owner))
      partner.send_packet(StatusUpdate.current_load(partner))

      success = true
    end

    partner_list.owner.on_trade_finish(success)
    @owner.on_trade_finish(success)
  end

  def private_store_buy(pc : L2PcInstance, items : Set(ItemRequest)) : Int32
    sync do
      return 1 if @locked

      unless validate
        lock
        return 1
      end

      unless @owner.online? && pc.online?
        return 1
      end

      slots = 0
      weight = 0
      total_price = 0i64

      owner_inv = @owner.inventory
      pc_inv = pc.inventory

      items.each do |item|
        found = false
        @items.each do |ti|
          if ti.l2id == item.l2id
            if ti.price == item.price
              if ti.count < item.count
                item.count = ti.count
              end
              found = true
            end
            break
          end
        end

        unless found
          if packaged?
            Util.punish(pc, "tried to cheat the package sell and buy only part of the package.")
            return 2
          end

          item.count = 0
          next
        end

        if Inventory.max_adena / item.count < item.price
          lock
          return 1
        end

        total_price += item.price * item.count

        if Inventory.max_adena < total_price || total_price < 0
          lock
          return 1
        end

        old_item = @owner.check_item_manipulation(item.l2id, item.count, "sell")
        if old_item.nil? || !old_item.tradeable?
          lock
          return 2
        end

        template = ItemTable[item.item_id]?
        next unless template

        weight += template.weight * item.count

        if !template.stackable?
          slots += item.count
        elsif pc_inv.get_item_by_item_id(item.item_id).nil?
          slots += 1
        end
      end

      if total_price > pc_inv.adena
        pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
        return 1
      end

      unless pc_inv.validate_weight(weight)
        pc.send_packet(SystemMessageId::WEIGHT_LIMIT_EXCEEDED)
        return 1
      end

      unless pc_inv.validate_capacity(slots)
        pc.send_packet(SystemMessageId::SLOTS_FULL)
        return 1
      end

      owner_iu = InventoryUpdate.new
      pc_iu = InventoryUpdate.new

      adena_item = pc_inv.adena_instance

      unless pc_inv.reduce_adena("PrivateStore", total_price, pc, @owner)
        pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
        return 1
      end

      pc_iu.add_item(adena_item)
      owner_inv.add_adena("PrivateStore", total_price, @owner, pc)

      ok = true

      items.each do |item|
        next if item.count == 0

        old_item = @owner.check_item_manipulation(item.l2id, item.count, "sell")
        unless old_item
          lock
          ok = false
          break
        end

        new_item = owner_inv.transfer_item("PrivateStore", item.l2id, item.count, pc_inv, @owner, pc)
        unless new_item
          ok = false
          break
        end

        remove_item(item.l2id, -1, item.count)

        if old_item.count > 0 && old_item != new_item
          owner_iu.add_modified_item(old_item)
        else
          owner_iu.add_removed_item(old_item)
        end

        if new_item.count > item.count
          pc_iu.add_modified_item(new_item)
        else
          pc_iu.add_new_item(new_item)
        end

        if new_item.stackable?
          sm = SystemMessage.c1_purchased_s3_s2_s
          sm.add_string(pc.name)
          sm.add_item_name(new_item)
          sm.add_long(item.count)
          @owner.send_packet(sm)

          sm = SystemMessage.purchased_s3_s2_s_from_c1
          sm.add_string(@owner.name)
          sm.add_item_name(new_item)
          sm.add_long(item.count)
          pc.send_packet(sm)
        else
          sm = SystemMessage.c1_purchased_s2
          sm.add_string(pc.name)
          sm.add_item_name(new_item)
          @owner.send_packet(sm)

          sm = SystemMessage.purchased_s2_from_c1
          sm.add_string(@owner.name)
          sm.add_item_name(new_item)
          pc.send_packet(sm)
        end
      end

      @owner.send_packet(owner_iu)
      pc.send_packet(pc_iu)

      ok ? 0 : 2
    end
  end

  def private_store_sell(pc : L2PcInstance, items : Array(ItemRequest)) : Bool
    sync do
      return false if @locked

      unless @owner.online? && pc.online?
        return false
      end

      ok = false

      owner_inv = @owner.inventory
      pc_inv = pc.inventory

      owner_iu = InventoryUpdate.new
      pc_iu = InventoryUpdate.new

      total_price = 0i64

      items.each do |item|
        found = false

        @items.each do |ti|
          if ti.item.id == item.item_id
            if ti.price == item.price
              if ti.count < item.count
                item.count = ti.count
              end

              found = item.count > 0
            end
            break
          end
        end

        next unless found

        if Inventory.max_adena / item.count < item.price
          lock
          break
        end

        total_price2 = total_price + (item.price * item.count)

        if Inventory.max_adena < total_price2 || total_price2 < 0
          lock
          break
        end

        if owner_inv.adena < total_price2
          next
        end

        l2id = item.l2id
        old_item = pc.check_item_manipulation(l2id, item.count, "sell")
        unless old_item
          unless old_item = pc_inv.get_item_by_item_id(item.item_id)
            next
          end
          l2id = old_item.l2id
          old_item = pc.check_item_manipulation(l2id, item.count, "sell")
          unless old_item
            next
          end
        end

        if old_item.id != item.item_id
          Util.punish(pc, "is cheating with sell items.")
          return false
        end

        next unless old_item.tradeable?

        new_item = pc_inv.transfer_item("PrivateStore", l2id, item.count, owner_inv, pc, @owner)
        unless new_item
          next
        end

        remove_item(-1, item.item_id, item.count)

        ok = true

        total_price = total_price2

        if old_item.count > 0 && old_item != new_item
          pc_iu.add_modified_item(old_item)
        else
          pc_iu.add_removed_item(old_item)
        end

        if new_item.count > item.count
          owner_iu.add_modified_item(new_item)
        else
          owner_iu.add_new_item(new_item)
        end

        if new_item.stackable?
          sm = SystemMessage.purchased_s3_s2_s_from_c1
          sm.add_string(pc.name)
          sm.add_item_name(new_item)
          sm.add_long(item.count)
          @owner.send_packet(sm)

          sm = SystemMessage.c1_purchased_s3_s2_s
          sm.add_string(@owner.name)
          sm.add_item_name(new_item)
          sm.add_long(item.count)
          pc.send_packet(sm)
        else
          sm = SystemMessage.purchased_s2_from_c1
          sm.add_string(pc.name)
          sm.add_item_name(new_item)
          @owner.send_packet(sm)

          sm = SystemMessage.c1_purchased_s2
          sm.add_string(@owner.name)
          sm.add_item_name(new_item)
          pc.send_packet(sm)
        end
      end

      if total_price > 0
        if total_price > owner_inv.adena
          return false # L2J believes this should never happen
        end

        adena_item = owner_inv.adena_instance
        owner_inv.reduce_adena("PrivateStore", total_price, @owner, pc)
        owner_iu.add_item(adena_item)
        pc_inv.add_adena("PrivateStore", total_price, pc, @owner)
        pc_iu.add_item(pc_inv.adena_instance)
      end

      if ok
        @owner.send_packet(owner_iu)
        pc.send_packet(pc_iu)
      end

      ok
    end
  end
end
