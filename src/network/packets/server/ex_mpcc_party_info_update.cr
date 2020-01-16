class Packets::Outgoing::ExMPCCPartyInfoUpdate < GameServerPacket
  @name : String
  @leader_id : Int32
  @member_count : Int32

  def initialize(party : L2Party, @mode : Int32)
    @name = party.leader.name
    @leader_id = party.leader_l2id
    @member_count = party.size
  end

  private def write_impl
    c 0xfe
    h 0x5b

    s @name
    d @leader_id
    d @member_count
    d @mode
  end
end
