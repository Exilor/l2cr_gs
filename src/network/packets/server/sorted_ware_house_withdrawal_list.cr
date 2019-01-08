class Packets::Outgoing::SortedWareHouseWithdrawalList < GameServerPacket
  def initialize(*a)
    debug "Not implemented." # it's very complicated and i suspect custom
  end

  def write_impl
    c 0x1f
  end
end
