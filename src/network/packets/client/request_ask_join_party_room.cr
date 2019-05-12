class Packets::Incoming::RequestAskJoinPartyRoom < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    return unless pc = active_char

    if target = L2World.get_player(@name)
      if target.processing_request?
        sm = SystemMessage.c1_is_busy_try_later
        sm.add_pc_name(target)
        pc.send_packet(sm)
      else
        pc.on_transaction_request(target)
        target.send_packet(ExAskJoinPartyRoom.new(pc.name))
      end
    else
      pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
    end
  end
end
