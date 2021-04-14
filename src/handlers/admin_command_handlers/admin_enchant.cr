module AdminCommandHandler::AdminEnchant
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command == "admin_enchant"
      show_main_page(pc)
    else
      armor_type =
      if command.starts_with?("admin_seteh")
        Inventory::HEAD
      elsif command.starts_with?("admin_setec")
        Inventory::CHEST
      elsif command.starts_with?("admin_seteg")
        Inventory::GLOVES
      elsif command.starts_with?("admin_setel")
        Inventory::FEET
      elsif command.starts_with?("admin_seteb")
        Inventory::LEGS
      elsif command.starts_with?("admin_setew")
        Inventory::RHAND
      elsif command.starts_with?("admin_setes")
        Inventory::LHAND
      elsif command.starts_with?("admin_setle")
        Inventory::LEAR
      elsif command.starts_with?("admin_setre")
        Inventory::REAR
      elsif command.starts_with?("admin_setlf")
        Inventory::LFINGER
      elsif command.starts_with?("admin_setrf")
        Inventory::RFINGER
      elsif command.starts_with?("admin_seten")
        Inventory::NECK
      elsif command.starts_with?("admin_setun")
        Inventory::UNDER
      elsif command.starts_with?("admin_setba")
        Inventory::CLOAK
      elsif command.starts_with?("admin_setbe")
        Inventory::BELT
      else
        -1
      end

      if armor_type != -1
        begin
          ench = command.from(12).to_i
        rescue e
          ench = 0
          warn e
        end
        if ench < 0 || ench > 65535
          pc.send_message("You must set the enchant level to be between 0-65535.")
        else
          set_enchant(pc, ench, armor_type)
        end
      end
    end

    show_main_page(pc)

    true
  end

  private def set_enchant(pc, ench, armor_type)
    player = pc.target || pc
    unless player.is_a?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    cur_enchant = 0
    parmor_instance = pc.inventory[armor_type]

    if parmor_instance && parmor_instance.location_slot == armor_type
      item_instance = parmor_instance
    end

    if item_instance
      cur_enchant = item_instance.enchant_level

      player.inventory.unequip_item_in_slot(armor_type)
      item_instance.enchant_level = ench
      player.inventory.equip_item(item_instance)

      player.send_packet(InventoryUpdate.modified(item_instance))
      player.broadcast_packet(CharInfo.new(player))
      player.send_packet(UserInfo.new(player))
      player.broadcast_packet(ExBrExtraUserInfo.new(player))

      pc.send_message("Changed enchantment of #{pc}'s #{item_instance.template.name} from #{cur_enchant} to #{ench}.")
      player.send_message("Admin has changed the enchantment of your #{item_instance.template.name} from #{cur_enchant} to #{ench}.")
    end
  end

  private def show_main_page(pc)
    AdminHtml.show_admin_html(pc, "enchant.htm")
  end

  def commands : Enumerable(String)
    {
      "admin_seteh",
      "admin_setec",
      "admin_seteg",
      "admin_setel",
      "admin_seteb",
      "admin_setew",
      "admin_setes",
      "admin_setle",
      "admin_setre",
      "admin_setlf",
      "admin_setrf",
      "admin_seten",
      "admin_setun",
      "admin_setba",
      "admin_setbe",
      "admin_enchant"
    }
  end
end
