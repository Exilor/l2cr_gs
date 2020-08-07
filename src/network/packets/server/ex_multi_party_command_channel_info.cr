class Packets::Outgoing::ExMultiPartyCommandChannelInfo < GameServerPacket
  initializer channel : L2CommandChannel

  private def write_impl
    c 0xfe
    h 0x31

    s @channel.leader.name
    d 0 # Channel loot 0 or 1
    d @channel.size

    @channel.parties.each do |p|
      s p.leader.name
      d p.leader_l2id
      d p.size
    end
  end
end
