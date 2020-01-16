class Packets::Incoming::RequestAnswerJoinPledge < GameClientPacket
  @answer = 0

  private def read_impl
    @answer = d
  end

  private def run_impl
    return unless pc = active_char
    unless requestor = pc.request.partner
      debug "Requestor not found."
      return
    end

    if @answer == 0
      sm = SystemMessage.you_did_not_respond_to_s1_clan_invitation
      sm.add_string(requestor.name)
      pc.send_packet(sm)
      sm = SystemMessage.s1_did_not_respond_to_clan_invitation
      sm.add_string(pc.name)
      requestor.send_packet(sm)
    else
      request_packet = requestor.request.request_packet

      unless request_packet.is_a?(RequestJoinPledge)
        debug "request_packet is not a RequestJoinPledge"
        return
      end

      clan = requestor.clan.not_nil!

      if clan.check_clan_join_condition(requestor, pc, request_packet.pledge_type)
        pc.send_packet(JoinPledge.new(requestor.clan_id))
        pc.pledge_type = request_packet.pledge_type
        if request_packet.pledge_type == L2Clan::SUBUNIT_ACADEMY
          pc.power_grade = 9
          pc.lvl_joined_academy = pc.level
        else
          pc.power_grade = 5
        end

        clan.add_clan_member(pc)
        pc_clan = pc.clan.not_nil!
        pc.clan_privileges = pc_clan.get_rank_privs(pc.power_grade)
        pc.send_packet(SystemMessageId::ENTERED_THE_CLAN)

        sm = SystemMessage.s1_has_joined_clan
        sm.add_string(pc.name)
        clan.broadcast_to_online_members(sm)

        if pc_clan.castle_id > 0
          CastleManager.get_castle_by_owner(pc_clan).not_nil!.give_residential_skills(pc)
        end

        if pc_clan.fort_id > 0
          FortManager.get_fort_by_owner(pc_clan).not_nil!.give_residential_skills(pc)
        end

        pc.send_skill_list

        add = PledgeShowMemberListAdd.new(pc)
        clan.broadcast_to_other_online_members(add, pc)
        clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))

        pc.send_packet(PledgeShowMemberListAll.new(clan, pc))
        pc.clan_join_expiry_time = 0
        pc.broadcast_user_info
      end
    end

    pc.request.on_request_response
  end
end
