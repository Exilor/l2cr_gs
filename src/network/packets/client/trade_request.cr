class Packets::Incoming::TradeRequest < GameClientPacket
  @id = 0

  private def read_impl
    @id = d
  end

  private def run_impl
    return unless pc = active_char

    unless pc.access_level.allow_transaction?
      pc.send_message("You access level does not allow trading.")
      action_failed
      return
    end

    # check bot penalty buff

    unless target = L2World.find_object(@id)
      info "L2Object with ID #{@id} not found in L2World."
      return
    end

    partner = target.acting_player

    unless pc.known_list.knows_object?(target)
      "#{target.name} isn't known by #{pc.name}."
      return
    end

    if target.instance_id != pc.instance_id && pc.instance_id != -1
      "#{target.name} is not in the same instance as #{pc.name}."
      return
    end

    if target.l2id == pc.l2id
      pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return
    end

    unless target.is_a?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    if target.in_olympiad_mode? || pc.in_olympiad_mode?
      pc.send_message("A user currently participating in the Olympiad cannot accept or request a trade.")
      return
    end

    info = pc.effect_list.get_buff_info_by_abnormal_type(AbnormalType::BOT_PENALTY)
    if info
      warn "TODO: BotReportTable"
      # info.effects.each do |effect|
      #   unless effect.check_condition(BotReportTable::TRADE_ACTION_BLOCK_ID)
      #     pc.send_packet(SystemMessageId::YOU_HAVE_BEEN_REPORTED_SO_ACTIONS_NOT_ALLOWED)
      #     action_failed
      #     return
      #   end
      # end
    end

    if !Config.alt_game_karma_player_can_trade && partner.karma > 0
      pc.send_message("You cannot request a trade while your target is in a chaotic state.")
      return
    end

    if Config.jail_disable_transaction && (pc.jailed? || partner.jailed?)
      pc.send_message("You cannot trade while you are in in jail.")
      return
    end

    if !pc.private_store_type.none? || !partner.private_store_type.none?
      pc.send_packet(SystemMessageId::CANNOT_TRADE_DISCARD_DROP_ITEM_WHILE_IN_SHOPMODE)
      return
    end

    if pc.processing_transaction?
      debug "#{pc} is already in a transaction."
      pc.send_packet(SystemMessageId::ALREADY_TRADING)
      return
    end

    if target.processing_request? || target.processing_transaction?
      debug "#{target} is already in a transaction."
      sm = SystemMessage.c1_is_busy_try_later
      sm.add_string(target.name)
      pc.send_packet(sm)
      return
    end

    if partner.trade_refusal?
      pc.send_message("That person is in trade refusal mode.")
      return
    end

    if BlockList.blocked?(partner, pc)
      sm = SystemMessage.s1_has_added_you_to_ignore_list
      sm.add_char_name(partner)
      pc.send_packet(sm)
      return
    end

    if pc.calculate_distance(target, true, false) > 150
      pc.send_packet(SystemMessageId::TARGET_TOO_FAR)
      return
    end

    pc.on_transaction_request(target)
    target.send_packet(SendTradeRequest.new(pc.l2id))
    sm = SystemMessage.request_c1_for_trade
    sm.add_string(target.name)
    pc.send_packet(sm)
  end
end
