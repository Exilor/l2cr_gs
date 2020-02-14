class Packets::Incoming::RequestWithdrawalPledge < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    unless clan = pc.clan
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_A_CLAN_MEMBER)
      return
    end

    if pc.clan_leader?
      pc.send_packet(SystemMessageId::CLAN_LEADER_CANNOT_WITHDRAW)
      return
    end

    if pc.in_combat?
      pc.send_packet(SystemMessageId::YOU_CANNOT_LEAVE_DURING_COMBAT)
      return
    end

    time = Time.ms + Time.days_to_ms(Config.alt_clan_join_days)
    clan.remove_clan_member(pc.l2id, time)

    sm = SystemMessage.s1_has_withdrawn_from_the_clan
    sm.add_string(pc.name)
    clan.broadcast_to_online_members(sm)
    clan.broadcast_to_online_members(PledgeShowMemberListDelete.new(pc.name))
    pc.send_packet(SystemMessageId::YOU_HAVE_WITHDRAWN_FROM_CLAN)
    pc.send_packet(SystemMessageId::YOU_MUST_WAIT_BEFORE_JOINING_ANOTHER_CLAN)
  end
end
