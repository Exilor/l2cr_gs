class Packets::Incoming::RequestFriendInvite < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    return unless pc = active_char

    friend = L2World.get_player(@name)

    if friend.nil? || (!friend.online? || friend.invisible?)
      pc.send_packet(SystemMessageId::THE_USER_YOU_REQUESTED_IS_NOT_IN_GAME)
      return
    end

    if friend == pc
      pc.send_packet(SystemMessageId::YOU_CANNOT_ADD_YOURSELF_TO_OWN_FRIEND_LIST)
      return
    end

    if pc.in_olympiad_mode? || friend.in_olympiad_mode?
      pc.send_packet(SystemMessageId::A_USER_CURRENTLY_PARTICIPATING_IN_THE_OLYMPIAD_CANNOT_SEND_PARTY_AND_FRIEND_INVITATIONS)
      return
    end

    if BlockList.blocked?(friend, pc)
      pc.send_message("You are in that player's block list.")
      return
    end

    if BlockList.blocked?(pc, friend)
      sm = SystemMessage.blocked_c1
      sm.add_char_name(friend)
      pc.send_packet(sm)
      return
    end

    if pc.friend?(friend.l2id)
      sm = SystemMessage.s1_already_in_friends_list
      sm.add_string(@name)
      pc.send_packet(sm)
      return
    end

    if friend.processing_request?
      sm = SystemMessage.c1_is_busy_try_later
      sm.add_string(@name)
      pc.send_packet(sm)
      return
    end

    pc.on_transaction_request(friend)
    friend.send_packet(FriendAddRequest.new(pc.name))
    sm = SystemMessage.you_requested_c1_to_be_friend
    sm.add_string(@name)
    pc.send_packet(sm)
  end
end
