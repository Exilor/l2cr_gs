class Packets::Incoming::RequestAnswerFriendInvite < GameClientPacket
  @response = 0

  private def read_impl
    @response = d
  end

  private def run_impl
    return unless pc = active_char
    return unless requestor = pc.active_requester

    if pc.friend?(requestor.l2id) || requestor.friend?(pc.l2id)
      sm = SystemMessage.s1_already_in_friends_list
      sm.add_char_name(pc)
      requestor.send_packet(sm)
      return
    end

    if @response == 1
      GameDB.friend.insert(pc, requestor)

      sm = SystemMessageId::YOU_HAVE_SUCCEEDED_INVITING_FRIEND
      requestor.send_packet(sm)

      sm = SystemMessage.s1_added_to_friends
      sm.add_string(pc.name)
      requestor.send_packet(sm)
      requestor.add_friend(pc.l2id)

      sm = SystemMessage.s1_joined_as_friend
      sm.add_string(requestor.name)
      pc.send_packet(sm)
      pc.add_friend(requestor.l2id)

      pc.send_packet(FriendPacket.new(true, requestor.l2id))
      requestor.send_packet(FriendPacket.new(true, pc.l2id))
    else
      requestor.send_packet(SystemMessageId::FAILED_TO_INVITE_A_FRIEND)
    end

    pc.active_requester = nil
    requestor.on_transaction_response
  end
end
