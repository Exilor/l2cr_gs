class Packets::Incoming::RequestJoinParty < GameClientPacket
  @name = ""
  @item_distribution_type_id = 0

  private def read_impl
    @name = s
    @item_distribution_type_id = d
  end

  private def run_impl
    return unless requestor = active_char

    unless target = L2World.get_player(@name)
      requestor.send_packet(SystemMessageId::FIRST_SELECT_USER_TO_INVITE_TO_PARTY)
      return
    end

    if client = target.client
      if client.detached?
        requestor.send_message("Player is in offline mode.")
        return
      end
    end

    if requestor.party_banned?
      requestor.send_packet(SystemMessageId::YOU_HAVE_BEEN_REPORTED_SO_PARTY_NOT_ALLOWED)
      requestor.action_failed
      return
    end

    unless target.visible_for?(requestor)
      requestor.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      return
    end

    if target.in_party?
      sm = SystemMessage.c1_is_already_in_party
      sm.add_string(target.name)
      requestor.send_packet(sm)
      return
    end

    if BlockList.blocked?(target, requestor)
      sm = SystemMessage.s1_has_added_you_to_ignore_list
      sm.add_char_name(target)
      requestor.send_packet(sm)
      return
    end

    if target == requestor
      requestor.send_packet(SystemMessageId::YOU_HAVE_INVITED_THE_WRONG_TARGET)
      return
    end

    if target.cursed_weapon_equipped? || requestor.cursed_weapon_equipped?
      requestor.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end

    if target.jailed? || requestor.jailed?
      requestor.send_message("You cannot invite a player while is in jail.")
      return
    end

    if target.in_olympiad_mode? || requestor.in_olympiad_mode?
      if target.in_olympiad_mode? != requestor.in_olympiad_mode? || target.olympiad_game_id != requestor.olympiad_game_id || target.olympiad_side != requestor.olympiad_side
        requestor.send_packet(SystemMessageId::A_USER_CURRENTLY_PARTICIPATING_IN_THE_OLYMPIAD_CANNOT_SEND_PARTY_AND_FRIEND_INVITATIONS)
        return
      end
    end

    sm = SystemMessage.c1_invited_to_party
    sm.add_char_name(target)
    requestor.send_packet(sm)

    if !requestor.in_party?
      create_new_party(target, requestor)
    else
      if requestor.party.in_dimensional_rift?
        requestor.send_message("You cannot invite a player when you are in the Dimensional Rift.")
      else
        add_target_to_party(target, requestor)
      end
    end
  end

  private def add_target_to_party(target, requestor)
    return unless party = requestor.party

    unless party.leader?(requestor)
      requestor.send_packet(SystemMessageId::ONLY_LEADER_CAN_INVITE)
      return
    end

    if party.size >= 9
      requestor.send_packet(SystemMessageId::PARTY_FULL)
      return
    end

    if party.pending_invitation? && !party.invitation_request_expired?
      requestor.send_packet(SystemMessageId::WAITING_FOR_ANOTHER_REPLY)
      return
    end

    if !target.processing_request?
      requestor.on_transaction_request(target)
      target.send_packet(AskJoinParty.new(requestor.name, party.distribution_type))
      party.pending_invitation = true
    else
      sm = SystemMessage.c1_is_busy_try_later
      sm.add_string(target.name)
      requestor.send_packet(sm)
    end
  end

  private def create_new_party(target, requestor)
    return unless type = PartyDistributionType[@item_distribution_type_id]?

    if !target.processing_request?
      target.send_packet(AskJoinParty.new(requestor.name, type))
      target.active_requester = requestor
      requestor.on_transaction_request(target)
      requestor.party_distribution_type = type
    else
      requestor.send_packet(SystemMessageId::WAITING_FOR_ANOTHER_REPLY)
    end
  end
end
