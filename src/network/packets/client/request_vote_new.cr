class Packets::Incoming::RequestVoteNew < GameClientPacket
  @target_id = 0

  private def read_impl
    @target_id = d
  end

  private def run_impl
    return unless pc = active_char
    target = pc.target

    unless target.is_a?(L2PcInstance)
      if target.nil?
        send_packet(SystemMessageId::SELECT_TARGET)
      else
        send_packet(SystemMessageId::TARGET_IS_INCORRECT)
      end

      return
    end

    return unless target.l2id == @target_id

    if target == pc
      send_packet(SystemMessageId::YOU_CANNOT_RECOMMEND_YOURSELF)
      return
    end

    if pc.recom_left <= 0
      send_packet(SystemMessageId::YOU_CURRENTLY_DO_NOT_HAVE_ANY_RECOMMENDATIONS)
      return
    end

    if pc.recom_have >= 255
      send_packet(SystemMessageId::YOUR_TARGET_NO_LONGER_RECEIVE_A_RECOMMENDATION)
      return
    end

    pc.give_recom(target)

    sm = SystemMessage.you_have_recommended_c1_you_have_s2_recommendations_left
    sm.add_pc_name(target)
    sm.add_int(pc.recom_left)
    send_packet(sm)

    sm = SystemMessage.you_have_been_recommended_by_c1
    sm.add_pc_name(pc)
    target.send_packet(sm)

    send_packet(UserInfo.new(pc))
    send_packet(ExBrExtraUserInfo.new(pc))
    target.broadcast_user_info
    send_packet(ExVoteSystemInfo.new(pc))
    target.send_packet(ExVoteSystemInfo.new(target))
  end
end
