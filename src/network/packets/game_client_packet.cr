require "./server/*"

abstract class GameClientPacket < MMO::IncomingPacket(GameClient)
  include Packets::Outgoing
  include Loggable

  def read : Bool
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

    if triggers_on_action_request? && (pc = active_char)
      if pc.spawn_protected? || pc.invul?
        pc.on_action_request
      end
    end
  rescue e
    error e
    client.close_now if is_a?(Packets::Incoming::EnterWorld)
  end

  abstract def run_impl

  private def send_packet(gsp : GameServerPacket)
    client.send_packet(gsp)
  end

  private def send_packet(id : SystemMessageId)
    send_packet(SystemMessage[id])
  end

  private def active_char : L2PcInstance?
    client.active_char
  end

  private def action_failed
    client.send_packet(ActionFailed::STATIC_PACKET)
  end

  private def flood_protectors : FloodProtectors
    client.flood_protectors
  end

  private def triggers_on_action_request? : Bool
    true
  end

  private macro no_action_request
    private def triggers_on_action_request? : Bool
      false
    end
  end
end
