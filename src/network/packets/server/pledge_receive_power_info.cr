class Packets::Outgoing::PledgeReceivePowerInfo < GameServerPacket
  initializer member : L2ClanMember

  private def write_impl
    c 0xfe
    h 0x3d

    d @member.power_grade
    s @member.name
    d @member.clan.not_nil!.get_rank_privs(@member.power_grade).mask
  end
end
