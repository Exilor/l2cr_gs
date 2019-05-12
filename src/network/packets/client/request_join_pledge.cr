class Packets::Incoming::RequestJoinPledge < GameClientPacket
  @target = 0
  getter pledge_type = 0

  private def read_impl
    @target = d
    @pledge_type = d
  end

  private def run_impl
    return unless pc = active_char
    return unless clan = pc.clan?

    unless target = L2World.get_player(@target)
      send_packet(SystemMessageId::YOU_HAVE_INVITED_THE_WRONG_TARGET)
      return
    end
    unless clan.check_clan_join_condition(pc, target, @pledge_type)
      return
    end

    unless pc.request.set_request(target, self)
      return
    end

    pledge_name = clan.name
    subpledge_name = clan.get_subpledge(@pledge_type).try &.name

    ask = AskJoinPledge.new(pc.l2id, subpledge_name, @pledge_type, pledge_name)
    target.send_packet(ask)
  end
end
