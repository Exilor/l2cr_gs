class Packets::Outgoing::JoinPledge < GameServerPacket
  initializer pledge_id : Int32

  private def write_impl
    c 0x2d
    d @pledge_id
  end
end
