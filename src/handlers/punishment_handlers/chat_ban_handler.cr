module PunishmentHandler::ChatBanHandler
  extend self
  extend PunishmentHandler

  def on_start(task)
    case task.affect
    when PunishmentAffect::CHARACTER
      l2id = task.key.to_s.to_i
      if pc = L2World.get_player(l2id)
        apply_to_player(pc)
      end
    when PunishmentAffect::ACCOUNT
      account = task.key.to_s
      if client = LoginServerClient.get_client(account)
        if pc = client.active_char
          apply_to_player(pc)
        else
          client.close_now
        end
      end
    when PunishmentAffect::IP
      ip = task.key.to_s
      L2World.players.each do |pc|
        if pc.ip_address == ip
          apply_to_player(pc)
        end
      end
    else
      # automatically added
    end

  end

  def on_end(task)
    case task.affect
    when PunishmentAffect::CHARACTER
      l2id = task.key.to_s.to_i
      if pc = L2World.get_player(l2id)
        remove_from_player(pc)
      end
    when PunishmentAffect::ACCOUNT
      account = task.key.to_s
      if client = LoginServerClient.get_client(account)
        if pc = client.active_char
          remove_from_player(pc)
        else
          client.close_now
        end
      end
    when PunishmentAffect::IP
      ip = task.key.to_s
      L2World.players.each do |pc|
        if pc.ip_address == ip
          remove_from_player(pc)
        end
      end
    else
      # automatically added
    end

  end

  private def apply_to_player(task, pc)
    delay = (task.expiration_time - Time.ms) // 1000
    if delay > 0
      if delay > 60
        pc.send_message("You've been chat banned for #{delay // 60} minutes.")
      else
        pc.send_message("You've been chat banned for #{delay} seconds.")
      end
    else
      pc.send_message("You've been permanently chat banned.")
    end

    pc.send_packet(EtcStatusUpdate.new(pc))
  end

  private def remove_from_player(pc)
    pc.send_message("Your chat ban has been lifted.")
    pc.send_packet(EtcStatusUpdate.new(pc))
  end

  def type
    PunishmentType::CHAT_BAN
  end
end