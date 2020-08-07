class Packets::Incoming::RequestSendFriendMsg < GameClientPacket
  @message = ""
  @receiver = ""

  private def read_impl
    @message = s
    @receiver = s
  end

  private def run_impl
    return unless pc = active_char

    if @message.empty? || @message.size > 300
      debug { "Invalid message size: #{@message.size}" }
      return
    end

    target_player = L2World.get_player(@receiver)

    if target_player.nil? || !target_player.friend?(pc.l2id)
      pc.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
      return
    end

    # TODO: chat log
    debug { "#{pc.name} -> #{@receiver}: '#{@message}'." }

    target_player.send_packet(L2FriendSay.new(pc.name, @receiver, @message))
  end
end
