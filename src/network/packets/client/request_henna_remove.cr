class Packets::Incoming::RequestHennaRemove < GameClientPacket
  @symbol_id = 0

  private def read_impl
    @symbol_id = d
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.transaction.try_perform_action("HennaRemove")
      debug "Flood detected."
      action_failed
      return
    end

    found = false

    1.upto(3) do |i|
      henna = pc.get_henna(i)

      if henna && henna.dye_id == @symbol_id
        if pc.adena >= henna.cancel_fee
          pc.remove_henna(i)
        else
          pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
          action_failed
        end
        found = true
        break
      end
    end

    unless found
      warn "Player #{pc} requested to remove a dye that he doesn't have."
      action_failed
    end
  end
end
