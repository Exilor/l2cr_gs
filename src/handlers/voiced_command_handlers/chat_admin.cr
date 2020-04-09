module VoicedCommandHandler::ChatAdmin
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"banchat", "unbanchat"}

  def use_voiced_command(cmd : String, pc : L2PcInstance, params : String) : Bool
    unless AdminData.has_access?(cmd, pc.access_level)
      return false
    end

    case cmd
    when COMMANDS[0]
      if params.empty?
        pc.send_message("Usage: .banchat name [minutes]")
        return true
      end

      st = params.split
      unless st.empty?
        name = st.shift
        expiration_time = 0i64
        unless st.empty?
          token = st.shift
          if token.num?
            expiration_time = Time.ms + (token.to_i64 * 60 * 1000)
          end
        end

        l2id = CharNameTable.get_id_by_name(name)
        if l2id > 0
          player = L2World.get_player(l2id)
          if player.nil? || !player.online?
            pc.send_message("Player #{name} is not online.")
            return false
          end
          if player.chat_banned?
            pc.send_message("Player #{name} is already chat banned.")
            return false
          end
          if player == pc
            pc.send_message("You can't chat ban yourself.")
            return false
          end
          if player.gm?
            pc.send_message("You can't chat ban a GM.")
            return false
          end
          if AdminData.has_access?(cmd, pc.access_level)
            pc.send_message("You can't chat ban a moderator.")
            return false
          end

          task = PunishmentTask.new(l2id, PunishmentAffect::CHARACTER, PunishmentType::CHAT_BAN, expiration_time, "Chat banned by moderator", pc.name)
          PunishmentManager.start_punishment(task)
          player.send_message("You have been chat banned by moderator #{pc.name}.")

          if expiration_time > 0
            pc.send_message("Player #{name} has been chat banned for #{expiration_time} minutes.")
          else
            pc.send_message("Player #{name} has been chat banned forever.")
          end
        else
          pc.send_message("Player #{name} not found.")
          return false
        end
      end
    when COMMANDS[1]
      if params.empty?
        pc.send_message("Usage: .unbanchat name")
        return true
      end

      st = params.split
      unless st.empty?
        name = st.shift
        l2id = CharNameTable.get_id_by_name(name)
        if l2id > 0
          player = L2World.get_player(l2id)
          if player.nil? || !player.online?
            pc.send_message("Player #{name} is not online.")
            return false
          end

          unless player.chat_banned?
            pc.send_message("Player #{name} is not chat banned.")
            return false
          end

          PunishmentManager.stop_punishment(l2id, PunishmentAffect::CHARACTER, PunishmentType::CHAT_BAN)

          pc.send_message("Player #{name} chat ban has been lifted.")
          player.send_message("Chat unbanned by moderator #{pc.name}.")
        else
          pc.send_message("Player #{name} not found.")
          return false
        end
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
