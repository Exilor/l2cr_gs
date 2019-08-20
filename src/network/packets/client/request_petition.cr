class Packets::Incoming::RequestPetition < GameClientPacket
  @content = ""
  @type = 0

  private def read_impl
    @content = s
    @type = d
  end

  private def run_impl
    return unless pc = active_char

    unless AdminData.gm_online?(false)
      pc.send_packet(SystemMessageId::NO_GM_PROVIDING_SERVICE_NOW)
      return
    end

    unless PetitionManager.petitioning_allowed?
      pc.send_packet(SystemMessageId::GAME_CLIENT_UNABLE_TO_CONNECT_TO_PETITION_SERVER)
      return
    end

    if PetitionManager.pending_petition_count == Config.max_petitions_pending
      pc.send_packet(SystemMessageId::PETITION_SYSTEM_CURRENT_UNAVAILABLE)
      return
    end

    total = PetitionManager.get_player_total_petition_count(pc) + 1
    if total > Config.max_petitions_per_player
      sm = SystemMessage.we_have_received_s1_petitions_today
      sm.add_int(total)
      pc.send_packet(sm)
      return
    end

    if @content.size > 255
      pc.send_packet(SystemMessageId::PETITION_MAX_CHARS_255)
      return
    end

    petition_id = PetitionManager.submit_petition(pc, @content, @type)

    sm = SystemMessage.petition_accepted_recent_no_s1
    sm.add_int(petition_id)
    pc.send_packet(sm)

    sm = SystemMessage.submitted_you_s1_th_petition_s2_left
    sm.add_int(total)
    sm.add_int(Config.max_petitions_per_player - total)
    pc.send_packet(sm)

    sm = SystemMessage.s1_petition_on_waiting_list
    sm.add_int(PetitionManager.pending_petition_count)
    pc.send_packet(sm)
  end
end
