class Packets::Outgoing::PledgeStatusChanged < GameServerPacket
  initializer clan : L2Clan

  def write_impl
    c 0xcd

    d @clan.leader_id
    d @clan.id
    d @clan.crest_id
    d @clan.ally_id
    d @clan.ally_crest_id
    q 0
  end
end
