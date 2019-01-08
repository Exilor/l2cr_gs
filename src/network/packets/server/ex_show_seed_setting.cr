class Packets::Outgoing::ExShowSeedSetting < GameServerPacket
  def initialize(@manor_id : Int32)
    debug "Not implemented."
  end

  def write_impl
    c 0x1f
  end
end
