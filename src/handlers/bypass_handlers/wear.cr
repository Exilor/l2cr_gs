module BypassHandler::Wear
  extend self
  extend BypassHandler

  def use_bypass(command : String, pc : L2PcInstance, target : L2Character?) : Bool
    return false unless target.is_a?(L2Npc) && Config.allow_wear

    st = command.split
    st.shift
    if st.empty?
      return false
    end

    show_wear_window(pc,  st.shift.to_i)

    true
  end

  private def show_wear_window(pc, val)
    unless buy_list = BuyListData.get_buy_list(val)
      warn { "Buy list with id #{val} not found." }
      pc.action_failed
      return
    end

    pc.inventory_blocking_status = true
    spl = ShopPreviewList.new(buy_list, pc.adena, pc.expertise_level)
    pc.send_packet(spl)
  end

  def commands : Enumerable(String)
    {"Wear"}
  end
end
