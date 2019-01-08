class Packets::Incoming::RequestTutorialClientEvent < GameClientPacket
  @event_id = 0

  def read_impl
    @event_id = d
  end

  def run_impl
    if pc = active_char
      OnPlayerTutorialClientEvent.new(pc, @event_id).async(pc)
    end
  end
end
