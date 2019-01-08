class Packets::Outgoing::ExEventMatchMessage < GameServerPacket
  initializer type: Int32, message: String

  def write_impl
    c 0xfe
    h 0x0f

    c @type
    s @message
  end
end
