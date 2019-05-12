class Packets::Incoming::RequestExAcceptJoinMPCC < GameClientPacket
  @response = 0

  private def read_impl
    @response = d
  end

  private def run_impl
    return unless pc = active_char
    return unless requestor = pc.active_requester

    if @response == 1
      unless requestor.party.in_command_channel?
        L2CommandChannel.new(requestor)
        requestor.send_packet(SystemMessageId::COMMAND_CHANNEL_FORMED)
        new_cc = true
      end

      requestor.party.command_channel.add_party(pc.party)

      unless new_cc
        pc.send_packet(SystemMessageId::JOINED_COMMAND_CHANNEL)
      end
    else
      requestor.send_message("The player declined to join your Command Channel.")
    end

    pc.active_requester = nil
    requestor.on_transaction_response
  end
end
