class Packets::Incoming::RequestPledgeSetMemberPowerGrade < GameClientPacket
  @member = ""
  @power_grade = 0

  private def read_impl
    @member = s
    @power_grade = d
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan

    unless pc.has_clan_privilege?(ClanPrivilege::CL_MANAGE_RANKS)
      return
    end

    unless member = clan.get_clan_member(@member)
      debug { "#{@member} not found in clan #{clan.name}." }
      return
    end

    if member.l2id == clan.leader_id
      return
    end

    if member.pledge_type == L2Clan::SUBUNIT_ACADEMY
      pc.send_message("You cannot change academy member grade")
      return
    end

    member.power_grade = @power_grade
    clan.broadcast_clan_status
  end
end
