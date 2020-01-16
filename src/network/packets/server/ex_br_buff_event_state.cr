class Packets::Outgoing::ExBrBuffEventState < GameServerPacket
  initializer type : Int32, value : Int32, state : Int32, end_time : Int32

  private def write_impl
    c 0xfe
    h 0xdb

    d @type
    d @value
    d @state
    d @end_time
  end
end
