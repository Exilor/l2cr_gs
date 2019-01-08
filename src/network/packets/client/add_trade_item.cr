class Packets::Incoming::AddTradeItem < GameClientPacket
  @trade_id = 0
  @l2id = 0
  @count = 0i64

  def read_impl
    @trade_id = d
    @l2id = d
    @count = q
  end

  def run_impl
    return unless pc = active_char

    unless trade = pc.active_trade_list
      warn "Character #{pc} requested item #{@l2id} add without active TradeList."
      return
    end

    partner = trade.partner

    if partner.nil? || !L2World.get_player(partner.l2id) || partner.active_trade_list.nil?
      if partner
        warn "Character #{pc} requested invalid trade object: #{@l2id}."
      end
      pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
      pc.cancel_active_trade
      return
    end

    partner_list = partner.active_trade_list.not_nil!

    if trade.confirmed? || partner_list.confirmed?
      pc.send_packet(SystemMessageId::CANNOT_ADJUST_ITEMS_AFTER_TRADE_CONFIRMED)
      return
    end

    unless pc.access_level.allow_transaction?
      pc.send_message("You access level does not allow trading.")
      pc.cancel_active_trade
      return
    end

    unless pc.validate_item_manipulation(@l2id, "trade")
      pc.send_packet(SystemMessageId::NOTHING_HAPPENED)
      return
    end

    if item = trade.add_item(@l2id, @count)
      pc.send_packet(TradeOwnAdd.new(item))
      trade.partner.try &.send_packet(TradeOtherAdd.new(item))
    end
  end
end
