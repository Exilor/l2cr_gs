class Packets::Incoming::SetPrivateStoreMsgBuy < GameClientPacket
  no_action_request

  MAX_MSG_LENGTH = 29

  @msg = ""

  private def read_impl
    @msg = s
  end

  private def run_impl
    return unless pc = active_char
    return unless buy_list = pc.buy_list
    if @msg.size > MAX_MSG_LENGTH
      Util.punish(pc, "tried to overflow the buy private store message.")
      return
    end
    buy_list.title = @msg
    send_packet(PrivateStoreMsgBuy.new(pc))
  end
end
