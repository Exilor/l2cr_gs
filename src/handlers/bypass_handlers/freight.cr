module BypassHandler::Freight
  extend self
  extend BypassHandler

  def use_bypass(command, pc, target)
    unless target.is_a?(L2Npc)
      return false
    end

    if command.casecmp?(commands[0])
      freight = pc.freight
      if freight.size > 0
        pc.active_warehouse = freight
        freight.items.safe_each do |item|
          if item.time_limited_item? && item.remaining_time <= 0
            freight.destroy_item("L2ItemInstance", item, pc, nil)
          end
        end
        pc.send_packet(WarehouseWithdrawalList.new(pc, WarehouseWithdrawalList::FREIGHT))
      else
        pc.send_packet(SystemMessageId::NO_ITEM_DEPOSITED_IN_WH)
      end
    elsif command.casecmp?(commands[1])
      if pc.account_chars.size < 1
        pc.send_packet(SystemMessageId::CHARACTER_DOES_NOT_EXIST)
      else
        pc.send_packet(PackageToList.new(pc.account_chars))
      end
    end

    false
  end

  def commands
    {"package_withdraw", "package_deposit"}
  end
end
