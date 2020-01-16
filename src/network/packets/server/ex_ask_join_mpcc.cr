class Packets::Outgoing::ExAskJoinMPCC < GameServerPacket
  initializer requestor_name : String

  private def write_impl
    c 0xfe
    h 0x1a

    s @requestor_name
  end
end
