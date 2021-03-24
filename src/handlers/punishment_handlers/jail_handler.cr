module PunishmentHandler::JailHandler
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
      if client = LoginServerThread.instance.get_client(account)
        if pc = client.active_char
          apply_to_player(pc)
        else
          client.close_now
        end
      end
    when PunishmentAffect::IP
      ip = task.key.to_s
      L2World.players.each do |pc2|
        if pc2.ip_address == ip
          apply_to_player(pc2)
        end
      end
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
      if client = LoginServerThread.instance.get_client(account)
        if pc = client.active_char
          remove_from_player(pc)
        else
          client.close_now
        end
      end
    when PunishmentAffect::IP
      ip = task.key.to_s
      L2World.players.each do |pc2|
        if pc2.ip_address == ip
          remove_from_player(pc2)
        end
      end
    end
  end

  private def apply_to_player(task, pc)
    pc.instance_id = 0
    pc.in_7s_dungeon = false

    if !TvTEvent.inactive? && TvTEvent.participant?(pc.l2id)
      TvTEvent.remove_participant(pc.l2id)
    end

    if OlympiadManager.registered_in_comp?(pc)
      OlympiadManager.remove_disconnected_competitor(pc)
    end


    ThreadPoolManager.schedule_general(TeleportTask.new(pc, L2JailZone.location_in), 2000)

    msg = NpcHtmlMessage.new
    if content = HtmCache.get_htm(pc, "data/html/jail_in.htm")
      content = content.gsub("%reason%", task.reason)
      content = content.gsub("%punishedBy%", task.punished_by)
      msg.html = content
    else
      msg.html = "<html><body>You have been put in jail by an admin.</body></html>"
    end

    pc.send_packet(msg)

    delay = (task.expiration_time &- Time.ms) // 1000
    if delay > 0
      if delay > 60
        pc.send_message("You've been jailed for #{delay // 60} minutes.")
      else
        pc.send_message("You've been jailed for #{delay} seconds.")
      end
    else
      pc.send_message("You've been permanently jailed.")
    end

    pc.send_packet(EtcStatusUpdate.new(pc))
  end

  private def remove_from_player(pc)
    task = TeleportTask.new(pc, L2JailZone.location_out)
    ThreadPoolManager.schedule_general(task, 2000)

    msg = NpcHtmlMessage.new
    if content = HtmCache.get_htm(pc, "data/html/jail_in.htm")
      msg.html = content
    else
      msg.html = "<html><body>You are free for now, respect server rules!</body></html>"
    end
    pc.send_packet(msg)
  end

  def type : PunishmentType
    PunishmentType::JAIL
  end
end
