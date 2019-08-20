class Packets::Incoming::RequestPetitionCancel < GameClientPacket
  private def read_impl
    # @unknown = d
  end

  private def run_impl
    return unless pc = active_char

    if PetitionManager.player_in_consultation?(pc)
      if pc.gm?
        PetitionManager.end_active_petition(pc)
      else
        pc.send_packet(SystemMessageId::PETITION_UNDER_PROCESS)
      end
    else
      if PetitionManager.player_petition_pending?(pc)
        if PetitionManager.cancel_active_petition(pc)
          count = Config.max_petitions_per_player - PetitionManager.get_player_total_petition_count(pc)

          sm = SystemMessage.petition_canceled_submit_s1_more_today
          sm.add_string(count.to_s)
          pc.send_packet(sm)

          msg = pc.name + " has canceled a pending petition."
          cs = CreatureSay.new(pc.l2id, Packets::Incoming::Say2::HERO_VOICE, "Petition System", msg)
          AdminData.broadcast_to_gms(cs)
        else
          pc.send_packet(SystemMessageId::FAILED_CANCEL_PETITION_TRY_LATER)
        end
      else
        pc.send_packet(SystemMessageId::PETITION_NOT_SUBMITTED)
      end
    end
  end
end
