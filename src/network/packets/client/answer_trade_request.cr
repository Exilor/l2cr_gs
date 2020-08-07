class Packets::Incoming::AnswerTradeRequest < GameClientPacket
  @response = 0

  private def read_impl
    @response = d
  end

  private def run_impl
    return unless pc = active_char

    unless pc.access_level.allow_transaction?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      action_failed
      return
    end

    partner = pc.active_requester

    if partner.nil?
      pc.send_packet(TradeDone::CANCEL)
      pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
      pc.active_requester = nil
      return
    elsif L2World.get_player(partner.l2id).nil?
      pc.send_packet(TradeDone::CANCEL)
      pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
      pc.active_requester = nil
      return
    end

    if @response == 1 && !partner.request_expired?
      pc.start_trade(partner)
    else
      sm = SystemMessage.c1_denied_trade_request
      sm.add_string(pc.name)
      partner.send_packet(sm)
    end

    pc.active_requester = nil
    partner.on_transaction_response
  end
end
