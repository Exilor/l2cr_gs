class Packets::Incoming::RequestOlympiadMatchList < GameClientPacket
  private COMMAND = "arenalist"

  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char
    return unless pc.in_observer_mode?

    if handler = BypassHandler[COMMAND]
      handler.use_bypass(COMMAND, pc, nil)
    end
  end
end
