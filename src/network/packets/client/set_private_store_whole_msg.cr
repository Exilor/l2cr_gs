class Packets::Incoming::SetPrivateStoreWholeMsg < GameClientPacket
  private MAX_MSG_LENGTH = 29

  @msg = ""

  private def read_impl
    @msg = s
  end

  private def run_impl
    return unless pc = active_char
    return unless sell_list = pc.sell_list

    if @msg.size > MAX_MSG_LENGTH
      Util.punish(pc, "tried to overflow the buy private store whole message.")
      return
    end

    sell_list.title = @msg
    send_packet(ExPrivateStoreSetWholeMsg.new(pc))
  end
end
