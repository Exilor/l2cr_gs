class Packets::Outgoing::ExAskModifyPartyLooting < GameServerPacket
  initializer name : String, party_distribution_type : PartyDistributionType

  def write_impl
    c 0xfe
    h 0xbf

    s @name
    d @party_distribution_type.to_i
  end
end
