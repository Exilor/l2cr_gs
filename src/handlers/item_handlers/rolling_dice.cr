module ItemHandler::RollingDice
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    pc = playable.acting_player
    item_id = item.id

    if pc.in_olympiad_mode?
      pc.send_packet(SystemMessageId::THIS_ITEM_IS_NOT_AVAILABLE_FOR_THE_OLYMPIAD_EVENT)
      return false
    end

    number = roll_dice(pc)

    if number == 0
      pc.send_packet(SystemMessageId::YOU_MAY_NOT_THROW_THE_DICE_AT_THIS_TIME_TRY_AGAIN_LATER)
      return false
    end

    dice = Dice.new(pc.l2id, item_id, number, pc.x - 30, pc.y - 30, pc.z)
    Broadcast.to_self_and_known_players(pc, dice)

    sm = SystemMessage.c1_rolled_s2
    sm.add_string(pc.name)
    sm.add_int(number)
    pc.send_packet(sm)
    if pc.inside_peace_zone?
      Broadcast.to_known_players(pc, sm)
    elsif party = pc.party
      party.broadcast_to_party_members(pc, sm)
    end

    true
  end

  private def roll_dice(pc)
    unless pc.flood_protectors.roll_dice.try_perform_action("roll dice")
      return 0
    end

    Rnd.rand(1..6)
  end
end
