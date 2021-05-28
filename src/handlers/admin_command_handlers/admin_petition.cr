module AdminCommandHandler::AdminPetition
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    petition_id = -1

    begin
      petition_id = command.split[1].to_i
    rescue e
      warn e
    end

    if command == "admin_view_petitions"
      PetitionManager.send_pending_petition_list(pc)
    elsif command.starts_with?("admin_view_petition")
      PetitionManager.view_petition(pc, petition_id)
    elsif command.starts_with?("admin_accept_petition")
      if PetitionManager.player_in_consultation?(pc)
        pc.send_packet(SystemMessageId::ONLY_ONE_ACTIVE_PETITION_AT_TIME)
        return true
      end

      if PetitionManager.petition_in_process?(petition_id)
        pc.send_packet(SystemMessageId::PETITION_UNDER_PROCESS)
        return true
      end

      unless PetitionManager.accept_petition(pc, petition_id)
        pc.send_packet(SystemMessageId::NOT_UNDER_PETITION_CONSULTATION)
      end
    elsif command.starts_with?("admin_reject_petition")
      unless PetitionManager.reject_petition(pc, petition_id)
        pc.send_packet(SystemMessageId::FAILED_CANCEL_PETITION_TRY_LATER)
      end
      PetitionManager.send_pending_petition_list(pc)
    elsif command == "admin_reset_petitions"
      if PetitionManager.petition_in_process?
        pc.send_packet(SystemMessageId::PETITION_UNDER_PROCESS)
        return false
      end
      PetitionManager.clear_pending_petitions
      PetitionManager.send_pending_petition_list(pc)
    elsif command.starts_with?("admin_force_peti")
      begin
        target = pc.target
        unless target.is_a?(L2PcInstance)
          pc.send_packet(SystemMessageId::TARGET_IS_INCORRECT)
          return false
        end

        val = command.from(15)

        petition_id = PetitionManager.submit_petition(target, val, 9)
        PetitionManager.accept_petition(pc, petition_id)
      rescue e
        pc.send_message("Usage: #force_peti text")
        return false
      end
    end

    true
  end

  def commands : Enumerable(String)
    {
      "admin_view_petitions",
      "admin_view_petition",
      "admin_accept_petition",
      "admin_reject_petition",
      "admin_reset_petitions",
      "admin_force_peti"
    }
  end
end
