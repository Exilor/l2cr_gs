class Packets::Incoming::RequestPledgeReorganizeMember < GameClientPacket
  @is_member_selected = 0
  @member_name = ""
  @new_pledge_type = 0
  @selected_member = ""

  private def read_impl
    @is_member_selected = d
    @member_name = s
    @new_pledge_type = d
    @selected_member = s
  end

  private def run_impl
    return if @is_member_selected == 0
    return unless pc = active_char
    return unless clan = pc.clan

    unless pc.has_clan_privilege?(ClanPrivilege::CL_MANAGE_RANKS)
      debug { "#{pc.name} isn't allowed to manage ranks." }
      return
    end

    unless member1 = clan.get_clan_member(@member_name)
      debug { "#{@member_name} not found in #{clan}." }
      return
    end

    if member1.l2id == clan.leader_id
      return
    end

    unless member2 = clan.get_clan_member(@selected_member)
      debug { "#{@selected_member} not found in #{clan}." }
      return
    end

    if member2.l2id == clan.leader_id
      return
    end

    old_pledge_type = member1.pledge_type
    if old_pledge_type == @new_pledge_type
      return
    end

    member1.pledge_type = @new_pledge_type
    member2.pledge_type = old_pledge_type
    clan.broadcast_clan_status
  end
end
