class Packets::Outgoing::PledgePowerGradeList < GameServerPacket
  initializer privs : Slice(L2Clan::RankPrivs)

  def write_impl
    c 0xfe
    h 0x3c

    d @privs.size
    @privs.each do |priv|
      d priv.rank
      d priv.party
    end
  end
end
