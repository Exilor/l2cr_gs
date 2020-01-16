class Packets::Incoming::RequestHennaItemInfo < GameClientPacket
  @symbol_id = 0

  private def read_impl
    @symbol_id = d
  end

  private def run_impl
    return unless pc = active_char

    henna = HennaData.get_henna(@symbol_id)

    unless henna
      if @symbol_id != 0
        warn { "Invalid henna ID #{@symbol_id} from player #{pc}." }
      end

      action_failed
      return
    end

    send_packet(HennaItemDrawInfo.new(henna, pc))
  end
end
