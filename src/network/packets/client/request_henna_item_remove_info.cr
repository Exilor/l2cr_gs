class Packets::Incoming::RequestHennaItemRemoveInfo < GameClientPacket
  @symbol_id = 0

  private def read_impl
    @symbol_id = d
  end

  private def run_impl
    return unless pc = active_char
    return if @symbol_id == 0

    unless henna = HennaData.get_henna(@symbol_id)
      warn { "Invalid henna id #{@symbol_id} from player #{pc}." }
      action_failed
      return
    end

    pc.send_packet(HennaItemRemoveInfo.new(henna, pc))
  end
end
