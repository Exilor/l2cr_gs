module PunishmentHandler::BanHandler
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
      if client = LoginServerClient.instance.get_client(account)
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
    end

  end

  def on_end(task)
    # no-op
  end

  private def apply_to_player(pc)
    pc.logout
  end

  def type
    PunishmentType::BAN
  end
end
