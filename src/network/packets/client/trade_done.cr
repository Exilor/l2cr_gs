class Packets::Incoming::TradeDone < GameClientPacket
  @response = 0

  def read_impl
    @response = d
  end

  def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("trade")
      pc.send_message("You are trading too fast.")
      return
    end

    unless trade = pc.active_trade_list
      warn "#{pc} doesn't have an active TradeList."
      return
    end

    return if trade.locked?

    if @response == 1
      partner = trade.partner?
      if !partner || !L2World.get_player(partner.l2id)
        pc.cancel_active_trade
        pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
        return
      end

      return if trade.owner.active_enchant_item_id != L2PcInstance::ID_NONE
      return if trade.partner.active_enchant_item_id != L2PcInstance::ID_NONE

      unless pc.access_level.allow_transaction?
        pc.cancel_active_trade
        pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
        return
      end

      if pc.instance_id != partner.instance_id && pc.instance_id != -1
        pc.cancel_active_trade
        return
      end

      if pc.calculate_distance(partner, true, false) > 150
        pc.cancel_active_trade
        return
      end

      trade.confirm
    else
      pc.cancel_active_trade
    end
  end
end
