module VoicedCommandHandler::CastkeVCmd
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"opendoors", "closedoors", "ridewyvern"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    case cmd
    when "opendoors"
      if params != "castle"
        pc.send_message("Only castle doors can be opened.")
        return false
      end

      unless (clan = pc.clan) && pc.clan_leader?
        pc.send_packet(SystemMessageId::ONLY_CLAN_LEADER_CAN_ISSUE_COMMANDS)
        return false
      end

      unless door = pc.target.as?(L2DoorInstance)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      unless castle = CastleManager.get_castle_by_id(clan.castle_id)
        pc.send_message("Your clan does not own a castle.")
        return false
      end

      if castle.siege.in_progress?
        pc.send_packet(SystemMessageId::GATES_NOT_OPENED_CLOSED_DURING_SIEGE)
        return false
      end

      if castle.in_zone?(*door.xyz)
        pc.send_packet(SystemMessageId::GATE_IS_OPENING)
        door.open_me
      end
    when "closedoors"
      if params != "castle"
        pc.send_message("Only castle doors can be closed.")
        return false
      end

      unless (clan = pc.clan) && pc.clan_leader?
        pc.send_packet(SystemMessageId::ONLY_CLAN_LEADER_CAN_ISSUE_COMMANDS)
        return false
      end

      unless door = pc.target.as?(L2DoorInstance)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      unless castle = CastleManager.get_castle_by_id(clan.castle_id)
        pc.send_message("Your clan does not own a castle.")
        return false
      end

      if castle.siege.in_progress?
        pc.send_packet(SystemMessageId::GATES_NOT_OPENED_CLOSED_DURING_SIEGE)
        return false
      end

      if castle.in_zone?(*door.xyz)
        pc.send_message("The gate is being closed.")
        door.close_me
      end
    when "ridewyvern"
      clan = pc.clan
      if clan && pc.clan_leader? && clan.castle_id > 0
        pc.mount(12621, 0, true)
      end
    else
      # [automatically added else]
    end


    true
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
