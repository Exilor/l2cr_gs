class Packets::Outgoing::ExAskJoinPartyRoom < GameServerPacket
  initializer name : String

  def write_impl
    c 0xfe
    h 0x35

    s @name
  end
end
