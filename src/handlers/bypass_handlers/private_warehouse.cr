module BypassHandler::PrivateWarehouse
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    return false unless target.is_a?(L2Npc)
    return false if pc.enchanting?

    if command.downcase.starts_with?(commands[0])
      if Config.enable_warehousesorting_private
        msg = NpcHtmlMessage.new(target.l2id)
        msg.set_file(pc, "data/html/mods/WhSortedP.htm")
        msg["%objectId%"] = target.l2id
        pc.send_packet(msg)
      else
        show_withdraw_window(pc)
      end

      true
    elsif command.downcase.starts_with?(commands[1])
      # don't bother
      param = command.split
      if param.size > 2
        # show_withdraw_window(pc, )
      elsif param.size > 1
      else
      end

      true
    elsif command.downcase.starts_with?(commands[2])
      pc.action_failed
      pc.active_warehouse = pc.warehouse
      pc.inventory_blocking_status = true
      packet = WarehouseDepositList.new(pc, WarehouseDepositList::PRIVATE)
      pc.send_packet(packet)
      true
    end

    false
  end

  private def show_withdraw_window(pc)
    pc.action_failed
    pc.active_warehouse = pc.warehouse
    if pc.active_warehouse.not_nil!.size == 0
      pc.send_packet(SystemMessage.no_item_deposited_in_wh)
      return
    end
    pc.send_packet(WarehouseWithdrawalList.new(pc, WarehouseWithdrawalList::PRIVATE))
  end

  def commands
    {"withdrawp", "withdrawsortedp", "depositp"}
  end
end
