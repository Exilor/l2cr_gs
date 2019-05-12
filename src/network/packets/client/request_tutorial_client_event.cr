class Packets::Incoming::RequestTutorialClientEvent < GameClientPacket
  @event_id = 0

  private def read_impl
    @event_id = d
  end

  private def run_impl
    if pc = active_char
      OnPlayerTutorialClientEvent.new(pc, @event_id).async(pc)
    end
  end
end
