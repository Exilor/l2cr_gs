module BypassHandler::ClanWarehouse
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target) : Bool
    unless target.is_a?(L2WarehouseInstance) || target.is_a?(L2ClanHallManagerInstance)
      return false
    end

    if pc.enchanting?
      return false
    end

    unless clan = pc.clan
      pc.send_packet(SystemMessageId::YOU_DO_NOT_HAVE_THE_RIGHT_TO_USE_CLAN_WAREHOUSE)
      return false
    end

    if clan.level == 0
      pc.send_packet(SystemMessageId::ONLY_LEVEL_1_CLAN_OR_HIGHER_CAN_USE_WAREHOUSE)
      return false
    end

    begin
      command = command.downcase

      if command.starts_with?(commands[0]) # WithdrawC
        if Config.enable_warehousesorting_clan
          msg = NpcHtmlMessage.new(target.l2id)
          msg.set_file(pc, "data/html/mods/WhSortedC.htm")
          msg["%objectId%"] = target.l2id
        else
          show_withdraw_window(pc, nil, 0)
        end
      elsif command.starts_with?(commands[1]) # WithdrawSortedC
        params = command.split
        warn "TODO: sorted withdrawal."
      elsif command.starts_with?(commands[2]) # DespositC
        pc.action_failed
        pc.active_warehouse = clan.warehouse
        pc.inventory_blocking_status = true
        wdl = WareHouseDepositList.new(pc, WareHouseDepositList::CLAN)
        pc.send_packet(wdl)
        return true
      end
    rescue e
      error e
    end

    false
  end

  private def show_withdraw_window(pc, item_type, sort_order)
    pc.action_failed

    unless pc.has_clan_privilege?(ClanPrivilege::CL_VIEW_WAREHOUSE)
      pc.send_packet(SystemMessageId::YOU_DO_NOT_HAVE_THE_RIGHT_TO_USE_CLAN_WAREHOUSE)
      return
    end

    wh = pc.clan.not_nil!.warehouse

    pc.active_warehouse = wh

    if wh.size == 0
      pc.send_packet(SystemMessageId::NO_ITEM_DEPOSITED_IN_WH)
      return
    end

    wh.items.safe_each do |item|
      if item.time_limited_item? && item.remaining_time <= 0
        wh.destroy_item("L2ItemInstance", item, pc, nil)
      end
    end

    if item_type
      wd = SortedWareHouseWithdrawalList.new(pc, WareHouseWithdrawalList::CLAN, item_type, sort_order)
    else
      wd = WareHouseWithdrawalList.new(pc, WareHouseWithdrawalList::CLAN)
    end

    pc.send_packet(wd)
  end

  def commands
    {"withdrawc", "withdrawsortedc", "depositc"}
  end
end
