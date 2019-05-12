class Packets::Incoming::RequestJoinAlly < GameClientPacket
  @id = 0

  private def read_impl
    @id = d
  end

  private def run_impl
    return unless pc = active_char

    unless target = L2World.get_player(@id)
      pc.send_packet(SystemMessageId::YOU_HAVE_INVITED_THE_WRONG_TARGET)
      return
    end

    unless clan = pc.clan?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_A_CLAN_MEMBER)
      return
    end

    unless clan.check_ally_join_condition(pc, target)
      return
    end

    unless pc.request.set_request(target, self)
      return
    end

    sm = SystemMessage.s2_alliance_leader_of_s1_requested_alliance
    sm.add_string(clan.ally_name.not_nil!)
    sm.add_string(pc.name)
    target.send_packet(sm)
    target.send_packet(AskJoinAlly.new(pc.l2id, clan.ally_name.not_nil!))
  end
end
