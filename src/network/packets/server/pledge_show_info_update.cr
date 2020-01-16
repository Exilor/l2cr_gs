class Packets::Outgoing::PledgeShowInfoUpdate < GameServerPacket
  initializer clan : L2Clan

  private def write_impl
    c 0x8e

    d @clan.id
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
  end
end
