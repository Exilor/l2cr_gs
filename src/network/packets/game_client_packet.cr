require "./server/*"

abstract class GameClientPacket < MMO::IncomingPacket(GameClient)
  include Packets::Outgoing
  include Loggable

  def trigger_on_action_request?
    true
  end

  private macro no_action_request
    def trigger_on_action_request?
      false
    end
  end

  def read
    read_impl
    true
  rescue e : IO::EOFError
    error e
    client.on_buffer_underflow
    false
  rescue e
    error e
    false
  end

  abstract def read_impl

  def run
    run_impl

    if trigger_on_action_request?
      if pc = active_char
        if pc.spawn_protected? || pc.invul?
          pc.on_action_request
          if Config.debug
            debug "Spawn protection for #{pc.name} removed."
          end
        end
      end
    end
  rescue e
    error e
    client.close_now
  end

  abstract def run_impl

  def send_packet(gsp : GameServerPacket)
    client.send_packet(gsp)
  end

  def send_packet(id : SystemMessageId)
    client.active_char.try &.send_packet(id)
  end

  def send_message(msg : String)
    client.active_char.try &.send_message(msg)
  end

  def active_char : L2PcInstance?
    client.active_char
  end

  def action_failed
    client.send_packet(ActionFailed::STATIC_PACKET)
  end

  def flood_protectors : FloodProtectors
    client.flood_protectors
  end
end
