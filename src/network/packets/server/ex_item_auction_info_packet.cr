class Packets::Outgoing::ExItemAuctionInfoPacket < GameServerPacket
  def initialize(*a)
    debug "Not implemented."
  end

  def write_impl
    c 0x1f
  end
end
