module AdminCommandHandler::AdminElement
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    armor_type =
      if command.starts_with?("admin_setlh")
        Inventory::HEAD
      elsif command.starts_with?("admin_setlc")
        Inventory::CHEST
      elsif command.starts_with?("admin_setlg")
        Inventory::GLOVES
      elsif command.starts_with?("admin_setlb")
        Inventory::FEET
      elsif command.starts_with?("admin_setll")
        Inventory::LEGS
      elsif command.starts_with?("admin_setlw")
        Inventory::RHAND
      elsif command.starts_with?("admin_setls")
        Inventory::LHAND
      end

    begin
      if armor_type
        args = command.split
        element = Elementals.get_element_id(args[1])
        value = args[2].to_i
        unless element.between?(-1, 5) && value.between?(0, 450)
          pc.send_message("Usage: //setlh/setlc/setlg/setlb/setll/setlw/setls <element> <value>[0-450]")
          return false
        end

        set_element(pc, element, value, armor_type)
      end
    rescue e
      pc.send_message("Usage: //setlh/setlc/setlg/setlb/setll/setlw/setls <element> <value>[0-450]")
      return false
    end

    true
  end

  private def set_element(pc, type, value, armor_type)
    debug "#set_element pc: #{pc}, type: #{type}, value: #{value}, armor_type: #{armor_type}"
    player = pc.target || pc

    unless player.is_a?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    item_instance = nil

    parmor_instance = player.inventory[armor_type]

    if parmor_instance && parmor_instance.location_slot == armor_type
      item_instance = parmor_instance
    end

    if item_instance
      if element = item_instance.get_elemental(type)
        old = element.to_s
      else
        old = "None"
      end

      player.inventory.unequip_item_in_slot(armor_type)

      if type == -1
        item_instance.clear_element_attr(type)
      else
        item_instance.set_element_attr(type, value)
      end

      player.inventory.equip_item(item_instance)

      if item_instance.elementals
        current = item_instance.get_elemental(type).to_s
      else
        current = "None"
      end

      iu = InventoryUpdate.modified(item_instance)
      player.send_packet(iu)

      pc.send_message("Changed the elemental power of #{player.name}'s #{item_instance.template.name} from #{old} to #{current}.")
      if player != pc
        player.send_message("#{pc.name} has changed the elemental power of your #{item_instance.template.name} from #{old} to #{current}.")
      end
    end
  end

  def commands
    {
      "admin_setlh",
      "admin_setlc",
      "admin_setll",
      "admin_setlg",
      "admin_setlb",
      "admin_setlw",
      "admin_setls"
    }
  end
end
