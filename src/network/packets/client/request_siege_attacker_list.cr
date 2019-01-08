class Packets::Incoming::RequestSiegeAttackerList < GameClientPacket
  @castle_id = 0

  def read_impl
    @castle_id = d
  end

  def run_impl
    if castle = CastleManager.get_castle_by_id(@castle_id)
      send_packet(SiegeAttackerList.new(castle))
    elsif hall = CHSiegeManager.get_siegable_hall(@castle_id)
      send_packet(SiegeAttackerList.new(hall))
    end
  end
end
