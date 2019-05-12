class Packets::Incoming::RequestHennaEquip < GameClientPacket
  @symbol_id = 0

  private def read_impl
    @symbol_id = d
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("HennaEquip")
      debug "Flood detected."
      return
    end

    if pc.henna_empty_slots == 0
      pc.send_packet(SystemMessageId::SYMBOLS_FULL)
      action_failed
      return
    end

    unless henna = HennaData.get_henna(@symbol_id)
      warn "Invalid henna ID #{@symbol_id} from player #{pc}."
      action_failed
      return
    end

    count = pc.inventory.get_inventory_item_count(henna.dye_item_id, -1)
    if henna.allowed_class?(pc.class_id) && count >= henna.wear_count && pc.adena >= henna.wear_fee && pc.add_henna(henna)
      pc.destroy_item_by_item_id("Henna", henna.dye_item_id, henna.wear_count.to_i64, pc, true)
      pc.inventory.reduce_adena("Henna", henna.wear_fee.to_i64, pc, pc.last_folk_npc)
      # iu = InventoryUpdate.new
      # iu.add_modified_item pc.inventory.adena_instance
      # send_packet(iu)
      send_packet(InventoryUpdate.modified(pc.inventory.adena_instance))
      send_packet(SystemMessageId::SYMBOL_ADDED)
    else
      send_packet(SystemMessageId::CANT_DRAW_SYMBOL)
      if !pc.override_item_conditions? && !henna.allowed_class?(pc.class_id)
        Util.punish(pc, "invalid class/dye combination.")
      end
      action_failed
    end
  end
end
