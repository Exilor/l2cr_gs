class Packets::Outgoing::PledgeInfo < GameServerPacket
  initializer clan : L2Clan

  def write_impl
    c 0x89

    d @clan.id
    s @clan.name
    s @clan.ally_name
  end
end
