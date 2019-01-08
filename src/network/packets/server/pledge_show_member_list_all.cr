class Packets::Outgoing::PledgeShowMemberListAll < GameServerPacket
  @members : Enumerable(L2ClanMember)
  @pledge_type = 0

  def initialize(@clan : L2Clan, @pc : L2PcInstance)
    @members = clan.members
  end

  def write_impl
    @pledge_type = 0
    write_pledge(0)
    @clan.all_subpledges.each do |subpledge|
      @pc.send_packet(PledgeReceiveSubPledgeCreated.new(subpledge, @clan))
    end
    @members.each do |m|
      next if m.pledge_type == 0
      @pc.send_packet(PledgeShowMemberListAdd.new(m))
    end

    # The client might not recognize the player as the clan leader without
    # sending this.
    @pc.send_packet(UserInfo.new(@pc))
    @pc.send_packet(ExBrExtraUserInfo.new(@pc))
  end

  private def write_pledge(main_or_subpledge)
    c 0x5a

    d main_or_subpledge
    d @clan.id
    d @pledge_type
    s @clan.name
    s @clan.leader_name

    d @clan.crest_id
    d @clan.level
    d @clan.castle_id
    d @clan.hideout_id
    d @clan.fort_id
    d @clan.rank
    d @clan.reputation_score
    q 0
    d @clan.ally_id
    s @clan.ally_name
    d @clan.ally_crest_id
    d @clan.at_war? ? 1 : 0
    d 0 # territory castle id
    d @clan.get_subpledge_members_count(@pledge_type)

    @members.each do |m|
      next unless m.pledge_type == @pledge_type

      s m.name
      d m.level
      d m.class_id

      # this is useless, the clan window doesn't show this
      if pc = m.player?
        d pc.appearance.sex ? 1 : 0
        d pc.race.to_i
      else
        d 1
        d 1
      end

      d m.online? ? m.l2id : 0
      d m.sponsor != 0 ? 1 : 0
    end
  end
end
