class Packets::Outgoing::GMViewPledgeInfo < GameServerPacket
  initializer clan: L2Clan, pc: L2PcInstance

  def write_impl
    c 0x96

    s @pc.name
    d @clan.id
    d 0
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
    d 0
    d @clan.members.size

    @clan.members.each do |member|
      s member.name
      d member.level
      d member.class_id
      d member.sex ? 1 : 0
      d member.race_ordinal
      d member.online? ? member.l2id : 0
      d member.sponsor != 0 ? 1 : 0
    end
  end
end
