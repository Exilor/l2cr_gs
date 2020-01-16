class Packets::Outgoing::PledgeReceiveSubPledgeCreated < GameServerPacket
  initializer subpledge : L2Clan::Subpledge, clan : L2Clan

  private def write_impl
    c 0xfe
    h 0x40

    d 1
    d @subpledge.id
    s @subpledge.name
    s leader_name
  end

  private def leader_name
    leader_id = @subpledge.leader_id
    if @subpledge.id == L2Clan::SUBUNIT_ACADEMY || leader_id == 0
      ""
    elsif @clan.get_clan_member(leader_id).nil?
      warn "Subpledge leader #{leader_id} is missing from clan #{@clan}."
      ""
    else
      @clan.get_clan_member(leader_id).not_nil!.name
    end
  end
end
