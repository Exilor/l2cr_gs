class Packets::Outgoing::ExChangeClientEffectInfo < GameServerPacket
  initializer type : Int32, key : Int32, value : Int32

  private def write_impl
    c 0xfe
    h 0xc2

    d @type
    d @key
    d @value
  end
end
