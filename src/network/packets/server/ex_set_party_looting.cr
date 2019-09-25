class Packets::Outgoing::ExSetPartyLooting < GameServerPacket
  initializer result : Int32, distribution_type : PartyDistributionType

  def write_impl
    c 0xfe
    h 0xc0

    d @result
    d @distribution_type.to_i
  end
end
