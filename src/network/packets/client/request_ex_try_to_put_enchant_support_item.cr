class Packets::Incoming::RequestExTryToPutEnchantSupportItem < GameClientPacket
  @support_l2id = 0
  @enchant_l2id = 0

  private def read_impl
    @support_l2id = d
    @enchant_l2id = d
  end

  private def run_impl
    return unless (pc = active_char) && pc.enchanting?

    item = pc.inventory.get_item_by_l2id(@enchant_l2id)
    scroll = pc.inventory.get_item_by_l2id(pc.active_enchant_item_id)
    support = pc.inventory.get_item_by_l2id(@support_l2id)

    unless item && scroll && support
      # Message may be wrong
      pc.send_packet(SystemMessageId::INAPPROPRIATE_ENCHANT_CONDITION)
      pc.active_enchant_support_item_id = L2PcInstance::ID_NONE
      return
    end

    enchant_scroll = EnchantItemData.get_enchant_scroll(scroll) # EnchantScroll
    support_item = EnchantItemData.get_support_item(support) # EnchantSupportItem

    if enchant_scroll.nil? || (support_item.nil? || !enchant_scroll.valid?(item, support_item))
      # Message may be wrong
      pc.send_packet(SystemMessageId::INAPPROPRIATE_ENCHANT_CONDITION)
      pc.active_enchant_support_item_id = L2PcInstance::ID_NONE
      pc.send_packet(ExPutEnchantSupportItemResult::ZERO)
      return
    end

    pc.active_enchant_support_item_id = support.l2id
    pc.send_packet(ExPutEnchantSupportItemResult.new(@support_l2id))
  end
end
