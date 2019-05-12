class Packets::Incoming::RequestSiegeDefenderList < GameClientPacket
  @castle_id = 0

  private def read_impl
    @castle_id = d
  end

  private def run_impl
    if castle = CastleManager.get_castle_by_id(@castle_id)
      send_packet(SiegeDefenderList.new(castle))
    end
  end
end
