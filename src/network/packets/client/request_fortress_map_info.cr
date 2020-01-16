class Packets::Incoming::RequestFortressMapInfo < GameClientPacket
  @fort_id = 0

  private def read_impl
    @fort_id = d
  end

  private def run_impl
    unless fort = FortManager.get_fort_by_id(@fort_id)
      warn { "Fort with id #{@fort_id} not found." }
      if active_char
        action_failed
      end

      return
    end

    send_packet(ExShowFortressMapInfo.new(fort))
  end
end
