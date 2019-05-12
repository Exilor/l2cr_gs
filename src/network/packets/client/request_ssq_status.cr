class Packets::Incoming::RequestSSQStatus < GameClientPacket
  @page = 0

  private def read_impl
    @page = c
  end

  private def run_impl
    return unless pc = active_char

    if SevenSigns.seal_validation_period? || SevenSigns.comp_results_period?
      if @page == 4
        return
      end
    end

    ssqs = SSQStatus.new(pc.l2id, @page)
    send_packet(ssqs)
  end
end
