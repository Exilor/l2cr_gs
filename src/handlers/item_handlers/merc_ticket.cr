module ItemHandler::MercTicket
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless pc = playable.as?(L2PcInstance)
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    item_id = item.id
    castle = CastleManager.get_castle(pc)
    castle_id = -1

    if castle
      castle_id = castle.residence_id
    end

    if MercTicketManager.get_ticket_castle_id(item_id) != castle_id
      pc.send_packet(SystemMessageId::MERCENARIES_CANNOT_BE_POSITIONED_HERE)
      return false
    elsif !pc.castle_lord?(castle_id)
      pc.send_packet(SystemMessageId::YOU_DO_NOT_HAVE_AUTHORITY_TO_POSITION_MERCENARIES)
      return false
    elsif castle && castle.siege.in_progress?
      pc.send_packet(SystemMessageId::THIS_MERCENARY_CANNOT_BE_POSITIONED_ANYMORE)
      return false
    end

    if SevenSigns.current_period != SevenSigns::PERIOD_SEAL_VALIDATION
      pc.send_packet(SystemMessageId::THIS_MERCENARY_CANNOT_BE_POSITIONED_ANYMORE)
      return false
    end

    case SevenSigns.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_NULL
      if SevenSigns.check_is_dawn_posting_ticket(item_id)
        pc.send_packet(SystemMessageId::THIS_MERCENARY_CANNOT_BE_POSITIONED_ANYMORE)
        return false
      end
    when SevenSigns::CABAL_DUSK
      unless SevenSigns.check_is_dawn_posting_ticket(item_id)
        pc.send_packet(SystemMessageId::THIS_MERCENARY_CANNOT_BE_POSITIONED_ANYMORE)
        return false
      end
    end

    if MercTicketManager.at_castle_limit?(item.id)
      pc.send_packet(SystemMessageId::THIS_MERCENARY_CANNOT_BE_POSITIONED_ANYMORE)
      return false
    elsif MercTicketManager.at_type_limit?(item.id)
      pc.send_packet(SystemMessageId::THIS_MERCENARY_CANNOT_BE_POSITIONED_ANYMORE)
      return false
    elsif MercTicketManager.too_close_to_another_ticket?(*pc.xyz)
      pc.send_packet(SystemMessageId::POSITIONING_CANNOT_BE_DONE_BECAUSE_DISTANCE_BETWEEN_MERCENARIES_TOO_SHORT)
      return false
    end

    MercTicketManager.add_ticket(item.id, pc)
    pc.destroy_item("Consume", item.l2id, 1, nil, false)
    pc.send_packet(SystemMessageId::PLACE_CURRENT_LOCATION_DIRECTION)

    true
  end
end
