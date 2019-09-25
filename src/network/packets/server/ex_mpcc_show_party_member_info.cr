class Packets::Outgoing::ExMPCCShowPartyMemberInfo < GameServerPacket
  initializer party : L2Party

  def write_impl
    c 0xfe
    h 0x4b

    d @party.size
    @party.members.each do |pc|
      s pc.name
      d pc.l2id
      d pc.class_id.to_i
    end
  end
end
