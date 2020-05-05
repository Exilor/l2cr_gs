class Packets::Incoming::Logout < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    unless pc = active_char
      return
    end

    if pc.active_enchant_item_id != L2PcInstance::ID_NONE || pc.active_enchant_attr_item_id != L2PcInstance::ID_NONE
      warn { "#{pc} tried to log out while enchanting." }
      action_failed
      return
    end

    if pc.locked?
      warn { "#{pc} tried to log out during class change." }
      action_failed
      return
    end

    if AttackStances.includes?(pc)
      unless pc.gm? && Config.gm_restart_fighting
        pc.send_packet(SystemMessageId::CANT_LOGOUT_WHILE_FIGHTING)
        action_failed
        return
      end
    end

    if L2Event.participant?(pc)
      pc.send_message("A superior power doesn't allow you to leave the event.")
      action_failed
      return
    end

    if pc.festival_participant?
      if SevenSignsFestival.instance.festival_initialized?
        pc.send_message("You cannot log out while you are a participant in a Festival.")
        action_failed
        return
      end

      if party = pc.party
        msg = "#{pc.name} has been removed from the upcoming Festival."
        sm = SystemMessage.from_string(msg)
        party.broadcast_packet(sm)
      end
    end

    pc.remove_from_boss_zone

    # TODO: log record

    pc.logout
  end
end
