class Packets::Incoming::ProtocolVersion < GameClientPacket
  @version = -1

  private def read_impl
    @version = d
  end

  private def run_impl
    if @version == -2
      debug "Ping received."
      client.close(nil)
    elsif Config.protocol_list.includes?(@version)
      debug { "Compatible protocol: #{@version}." }
      client.protocol_ok = true
      send_packet(KeyPacket.new(client.enable_crypt, true))
    else
      Logs[:accounting].warn { "Wrong protocol from #{client}: #{@version}." }
      client.protocol_ok = false
      send_packet(KeyPacket.new(client.enable_crypt, false))
    end
  end
end
