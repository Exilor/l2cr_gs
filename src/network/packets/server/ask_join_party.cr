class Packets::Outgoing::AskJoinParty < GameServerPacket
  initializer name : String, party_distribution_type : PartyDistributionType

  def write_impl
    c 0x39

    s @name
    d @party_distribution_type.to_i
  end
end
