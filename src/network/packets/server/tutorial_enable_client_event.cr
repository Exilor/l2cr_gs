class Packets::Outgoing::TutorialEnableClientEvent < GameServerPacket
  initializer event : Int32

  private def write_impl
    c 0xa8
    d @event
  end
end
