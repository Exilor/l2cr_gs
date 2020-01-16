module UserCommandHandler::OlympiadStat
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    unless id == commands[0]
      return false
    end

    l2id = pc.l2id
    if target = pc.target
      if target.is_a?(L2PcInstance) && target.noble?
        l2id = target.l2id
      else
        pc.send_packet(SystemMessageId::NOBLESSE_ONLY)
        return false
      end
    elsif !pc.noble?
      pc.send_packet(SystemMessageId::NOBLESSE_ONLY)
      return false
    end

    ol = Olympiad.instance

    sm = Packets::Outgoing::SystemMessage.the_current_record_for_this_olympiad_session_is_s1_matches_s2_wins_s3_defeats_you_have_earned_s4_olympiad_points
    sm.add_int(ol.get_competition_done(l2id))
    sm.add_int(ol.get_competition_won(l2id))
    sm.add_int(ol.get_competition_lost(l2id))
    sm.add_int(ol.get_noble_points(l2id))
    pc.send_packet(sm)

    sm = Packets::Outgoing::SystemMessage.you_have_s1_matches_remaining_that_you_can_partecipate_in_this_week_s2_classed_s3_non_classed_s4_team
    sm.add_int(ol.get_remaining_weekly_matches(l2id))
    sm.add_int(ol.get_remaining_weekly_matches_classed(l2id))
    sm.add_int(ol.get_remaining_weekly_matches_non_classed(l2id))
    sm.add_int(ol.get_remaining_weekly_matches_team(l2id))
    pc.send_packet(sm)

    true
  end

  def commands
    {109}
  end
end
