class Packets::Outgoing::ExBrBroadcastEventState < GameServerPacket
  APRIL_FOOLS = 20090401
  EVAS_INFERNO = 20090801 # event state (0 - hide, 1 - show), day (1-14), percent (0-100)
  HALLOWEEN_EVENT = 20091031 # event state (0 - hide, 1 - show)
  RAISING_RUDOLPH = 20091225 # event state (0 - hide, 1 - show)
  LOVERS_JUBILEE = 20100214 # event state (0 - hide, 1 - show)

  @param0 = 0
  @param1 = 0
  @param2 = 0
  @param3 = 0
  @param4 = 0
  @param5 : String?
  @param6 : String?

  initializer event_id : Int32, event_state : Int32
  initializer event_id : Int32, event_state : Int32, param0 : Int32,
    param1 : Int32, param2 : Int32, param3 : Int32, param4 : Int32,
    param5 : String, param6 : String

  private def write_impl
    c 0xfe
    h 0xbc

    d @event_id
    d @event_state
    d @param0
    d @param1
    d @param2
    d @param3
    d @param4
    s @param5
    s @param6
  end
end
