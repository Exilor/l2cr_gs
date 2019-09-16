class Packets::Incoming::ProtocolVersion < GameClientPacket
  @version = -1

  private def read_impl
    @version = d
  end

  private def run_impl
    if @version == -2
      if Config.debug
        debug "Ping received."
      end
      client.close(nil)
    elsif Config.protocol_list.includes?(@version)
      debug "Compatible protocol: #{@version}."
      client.protocol_ok = true
      send_packet(KeyPacket.new(client.enable_crypt, true))
    else
      warn "Incompatible protocol #{@version}."
      client.protocol_ok = false
      send_packet(KeyPacket.new(client.enable_crypt, false))
    end
  end
end
