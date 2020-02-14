class Packets::Outgoing::ExChangeClientEffectInfo < GameServerPacket
  initializer type : Int32, key : Int32, value : Int32

  private def write_impl
    c 0xfe
    h 0xc2

    d @type
    d @key
    d @value
  end

  FREYA_DEFAULT = new(0, 0, 1)
  FREYA_DESTROYED = new(0, 0, 2)
end
