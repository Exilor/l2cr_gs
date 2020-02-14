class Packets::Outgoing::ExGetBossRecord < GameServerPacket
  initializer ranking : Int32, total_score : Int32, list : Hash(Int32, Int32)?

  private def write_impl
    c 0xfe
    h 0x34

    d @ranking
    d @total_score
    if list = @list
      d list.size
      list.each do |boss_id, info|
        d boss_id
        d info
        d 0
      end
    else
      q 0
      q 0
    end
  end
end
