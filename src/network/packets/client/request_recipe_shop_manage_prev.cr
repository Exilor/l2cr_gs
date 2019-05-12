class Packets::Incoming::RequestRecipeShopManagePrev < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    if pc.looks_dead?
      action_failed
      return
    end

    target = pc.target

    unless target.is_a?(L2PcInstance)
      action_failed
      return
    end

    send_packet(RecipeShopSellList.new(pc, target))
  end
end
