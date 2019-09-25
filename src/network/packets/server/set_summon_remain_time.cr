class Packets::Outgoing::SetSummonRemainTime < GameServerPacket
  initializer max_time : Int32, remaining_time : Int32

  def write_impl
    c 0xd1

    d @max_time
    d @remaining_time
  end
end
