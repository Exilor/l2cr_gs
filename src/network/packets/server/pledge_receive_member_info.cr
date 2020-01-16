class Packets::Outgoing::PledgeReceiveMemberInfo < GameServerPacket
  initializer member : L2ClanMember

  private def write_impl
    c 0xfe
    h 0x3e

    d @member.pledge_type
    s @member.name
    s @member.title
    d @member.power_grade

    if @member.pledge_type != 0
      s @member.clan.not_nil!.get_subpledge(@member.pledge_type).try &.name
    else
      s @member.clan.not_nil!.name
    end

    s @member.apprentice_or_sponsor_name
  end
end
