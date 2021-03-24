module BypassHandler::ReceivePremium
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    unless target && target.npc?
      return false
    end

    if pc.premium_item_list.empty?
      pc.send_packet(SystemMessageId::THERE_ARE_NO_MORE_VITAMIN_ITEMS_TO_BE_FOUND)
      return false
    end

    pc.send_packet(ExGetPremiumItemList.new(pc))
    true
  end

  def commands : Enumerable(String)
    {"ReceivePremium"}
  end
end
