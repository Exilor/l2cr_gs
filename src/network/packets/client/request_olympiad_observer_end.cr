class Packets::Incoming::RequestOlympiadObserverEnd < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char

    if pc.in_observer_mode?
      pc.leave_olympiad_observer_mode
    end
  end
end
