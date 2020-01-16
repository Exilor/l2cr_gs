class Packets::Incoming::RequestExTryToPutEnchantTargetItem < GameClientPacket
  @l2id = 0

  private def read_impl
    @l2id = d
  end

  private def run_impl
    return if @l2id == 0
    return unless pc = active_char
    if pc.enchanting?
      debug { "#{pc} is already enchanting." }
      return
    end

    item = pc.inventory.get_item_by_l2id(@l2id)
    unless item
      warn { "Item with l2id #{@l2id} not found in #{pc.name}'s inventory." }
      return
    end

    scroll = pc.inventory.get_item_by_l2id(pc.active_enchant_item_id)
    unless scroll
      warn { "Enchant scroll with item_id #{pc.active_enchant_item_id.inspect} not found in #{pc.name}'s inventory." }
      return
    end

    scroll_template = EnchantItemData.get_enchant_scroll(scroll)

    unless scroll_template && scroll_template.valid?(item, nil)
      send_packet(SystemMessageId::DOES_NOT_FIT_SCROLL_CONDITIONS)
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
      pc.send_packet(ExPutEnchantTargetItemResult.new(0))
      unless scroll_template
        warn { "No template found for scroll with l2id #{scroll.l2id}." }
      end
      return
    end

    pc.enchanting = true
    pc.active_enchant_timestamp = Time.ms
    pc.send_packet(ExPutEnchantTargetItemResult.new(@l2id))
  end
end
