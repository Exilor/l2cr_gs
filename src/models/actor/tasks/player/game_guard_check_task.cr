struct GameGuardCheckTask
  initializer pc : L2PcInstance

  def call
    unless client = @pc.client?
      return
    end

    if !client.game_guard_ok? && @pc.online?
      msg = "Client #{client} failed to reply GameGuard query and is being kicked!"
      AdminData.broadcast_message_to_gms(msg)
      client.close(Packets::Outgoing::LeaveWorld::STATIC_PACKET)
    end
  end
end
