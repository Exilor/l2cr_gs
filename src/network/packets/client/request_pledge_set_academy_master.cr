class Packets::Incoming::RequestPledgeSetAcademyMaster < GameClientPacket
  @set = 0
  @current_player_name = ""
  @target_player_name = ""

  private def read_impl
    @set = d
    @current_player_name = s
    @target_player_name = s
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan

    unless pc.has_clan_privilege?(ClanPrivilege::CL_APPRENTICE)
      pc.send_packet(SystemMessageId::YOU_DO_NOT_HAVE_THE_RIGHT_TO_DISMISS_AN_APPRENTICE)
      return
    end

    unless current_member = clan.get_clan_member(@current_player_name)
      debug { "#{@current_player_name} not found in #{clan}." }
      return
    end

    unless target_member = clan.get_clan_member(@target_player_name)
      debug { "#{@target_player_name} not found in #{clan}." }
      return
    end

    if current_member.pledge_type == L2Clan::SUBUNIT_ACADEMY
      apprentice_member = current_member
      sponsor_member = target_member
    else
      apprentice_member = target_member
      sponsor_member = current_member
    end

    apprentice = apprentice_member.player_instance
    sponsor = sponsor_member.player_instance

    if @set == 0
      if apprentice
        apprentice.sponsor = 0
      else
        apprentice_member.set_apprentice_and_sponsor(0, 0)
      end

      if sponsor
        sponsor.apprentice = 0
      else
        sponsor_member.set_apprentice_and_sponsor(0, 0)
      end

      apprentice_member.save_apprentice_and_sponsor(0, 0)
      sponsor_member.save_apprentice_and_sponsor(0, 0)

      sm = SystemMessage.s2_clan_member_c1_apprentice_has_been_removed
    else
      if apprentice_member.sponsor != 0 || sponsor_member.apprentice != 0 || apprentice_member.apprentice != 0 || sponsor_member.sponsor != 0
        # L2J TODO: retail message.
        pc.send_message("Remove previous connections first.")
        return
      end

      if apprentice
        apprentice.sponsor = sponsor_member.l2id
      else
        apprentice_member.set_apprentice_and_sponsor(0, sponsor_member.l2id)
      end

      if sponsor
        sponsor.apprentice = apprentice_member.l2id
      else
        sponsor_member.set_apprentice_and_sponsor(apprentice_member.l2id, 0)
      end

      sm = SystemMessage.s2_has_been_designated_as_apprentice_of_clan_member_s1
    end

    sm.add_string(sponsor_member.name)
    sm.add_string(apprentice_member.name)

    if sponsor != pc && sponsor != apprentice
      pc.send_packet(sm)
    end

    sponsor.try &.send_packet(sm)
    apprentice.try &.send_packet(sm)
  end
end
