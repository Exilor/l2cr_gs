class Packets::Outgoing::PartySmallWindowAdd < GameServerPacket
  initializer member: L2PcInstance, party: L2Party

  def write_impl
    c 0x4f

    d @party.leader_l2id
    d @party.distribution_type.to_i
    d @member.l2id
    s @member.name

    d @member.current_cp
    d @member.max_cp
    d @member.current_hp
    d @member.max_hp
    d @member.current_mp
    d @member.max_mp
    d @member.level
    d @member.class_id.to_i
    q 0x00 # unknown
  end
end
