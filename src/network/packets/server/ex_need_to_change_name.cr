class Packets::Outgoing::ExNeedToChangeName < GameServerPacket
  initializer type : Int32, subtype : Int32, name : String

  private def write_impl
    c 0xfe
    h 0x69

    d @type
    d @subtype
    s @name
  end
end
