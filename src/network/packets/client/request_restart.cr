class Packets::Incoming::RequestRestart < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    return unless pc = active_char

    unless pc.private_store_type.none?
      pc.send_message("Cannot restart while trading")
      send_packet(RestartResponse::NO)
      return
    end

    if pc.active_enchant_item_id != L2PcInstance::ID_NONE
      send_packet(RestartResponse::NO)
      return
    end

    if pc.active_enchant_attr_item_id != L2PcInstance::ID_NONE
      send_packet(RestartResponse::NO)
      return
    end

    if pc.locked?
      warn "Player #{pc.name} tried to restart during class change."
      send_packet(RestartResponse::NO)
      return
    end

    unless pc.private_store_type.none?
      pc.send_message("Cannot restart while trading.")
      send_packet(RestartResponse::NO)
      return
    end

    if AttackStances.includes?(pc) && !(pc.gm? && Config.gm_restart_fighting)
      pc.send_packet(SystemMessageId::CANT_RESTART_WHILE_FIGHTING)
      send_packet(RestartResponse::NO)
      return
    end

    if pc.festival_participant?
      if SevenSignsFestival.festival_initialized?
        pc.send_message("You cannot restart while you are a participant in a festival.")
        send_packet(RestartResponse::NO)
        return
      end

      if party = pc.party?
        party.broadcast_string("#{pc.name} has been removed from the upcoming festival.")
      end
    end

    if pc.blocked_from_exit?
      send_packet(RestartResponse::NO)
      return
    end

    pc.remove_from_boss_zone

    pc.client = nil
    pc.delete_me
    client.active_char = nil
    client.state = :AUTHED
    send_packet(RestartResponse::YES)

    csi = CharSelectionInfo.new(client.account_name, client.session_id.play_ok_1)
    send_packet(csi)
    client.char_selection = csi.char_info
  end
end
