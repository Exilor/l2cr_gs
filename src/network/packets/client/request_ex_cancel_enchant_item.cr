class Packets::Incoming::RequestExCancelEnchantItem < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    pc.send_packet(EnchantResult::ERROR)
    pc.active_enchant_item_id = L2PcInstance::ID_NONE
  end
end
