class Packets::Incoming::RequestGetItemFromPet < GameClientPacket
  @l2id = 0
  @amount = 0i64
  @unknown = 0

  private def read_impl
    @l2id = d
    @amount = q
    @unknown = d # 0 for most trades
  end

  private def run_impl
    return unless pc = active_char
    return unless pet = pc.summon.as?(L2PetInstance)

    if @amount <= 0
      return
    end

    unless flood_protectors.transaction.try_perform_action("getfrompet")
      pc.send_message("You are taking items from your pet too fast.")
      return
    end

    unless pc.active_enchant_item_id == L2PcInstance::ID_NONE
      debug "#{pc.name} is enchanting an item."
      return
    end

    unless item = pet.inventory.get_item_by_l2id(@l2id)
      debug "Item with l2id #{@l2id} not found in #{pc.name}'s pet."
      return
    end

    if @amount > item.count
      Util.punish(pc, "tried to get item with object id #{@l2id} from pet but the count is invalid (#{@amount}/#{item.count}).")
      warn "#{@amount} > #{item.count}"
      return
    end

    unless pet.transfer_item("Transfer", @l2id, @amount, pc.inventory, pc, pet)
      warn "Invalid item transfer request from #{pet} to #{pc}."
    end

    pc.send_packet(ItemList.new(pc, false)) # custom
    pc.send_packet(StatusUpdate.current_load(pc)) # custom
  end
end
