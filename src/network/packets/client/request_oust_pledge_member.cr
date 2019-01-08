class Packets::Incoming::RequestOustPledgeMember < GameClientPacket
  @target = ""

  def read_impl
    @target = s
  end

  def run_impl
    return unless pc = active_char

    unless clan = pc.clan?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_A_CLAN_MEMBER)
      return
    end

    unless pc.has_clan_privilege?(ClanPrivilege::CL_DISMISS)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    if pc.name.casecmp?(@target)
      pc.send_packet(SystemMessageId::YOU_CANNOT_DISMISS_YOURSELF)
      return
    end

    unless member = clan.get_clan_member(@target)
      warn "Target #{@target.inspect} is not a member of clan #{clan.name}."
      return
    end

    if member.online? && member.player.in_combat?
      pc.send_packet(SystemMessageId::CLAN_MEMBER_CANNOT_BE_DISMISSED_DURING_COMBAT)
      return
    end

    time = Time.ms + Time.days_to_ms(Config.alt_clan_join_days)
    clan.remove_clan_member(member.l2id, time)
    clan.char_penalty_expiry_time = time
    clan.update_clan_in_db

    sm = SystemMessage.clan_member_s1_expelled
    sm.add_string(member.name)
    clan.broadcast_to_online_members(sm)

    pc.send_packet(SystemMessageId::YOU_HAVE_SUCCEEDED_IN_EXPELLING_CLAN_MEMBER)
    pc.send_packet(SystemMessageId::YOU_MUST_WAIT_BEFORE_ACCEPTING_A_NEW_MEMBER)

    clan.broadcast_to_online_members(PledgeShowMemberListDelete.new(@target))

    if member.online?
      member.player.send_packet(SystemMessageId::CLAN_MEMBERSHIP_TERMINATED)
    end
  end
end
