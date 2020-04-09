module AdminCommandHandler::AdminGrandBoss
  extend self
  extend AdminCommandHandler

  private ANTHARAS      = 29068
  private ANTHARAS_ZONE = 70050
  private VALAKAS       = 29028
  private BAIUM         = 29020
  private BAIUM_ZONE    = 70051
  private QUEENANT      = 29001
  private ORFEN         = 29014
  private CORE          = 29006

  def use_admin_command(command, pc)
    st = command.split
    actual_command = st.shift
    case actual_command.downcase
    when "admin_grandboss"
      if !st.empty?
        boss_id = st.shift.to_i
        manage_html(pc, boss_id)
      else
        html = NpcHtmlMessage.new(0, 1)
        html.html = HtmCache.get_htm(pc, "data/html/admin/grandboss.htm").not_nil!
        pc.send_packet(html)
      end
    when "admin_grandboss_skip"
      if !st.empty?
        boss_id = st.shift.to_i

        if boss_id == ANTHARAS
          antharas_ai.notify_event("SKIP_WAITING", nil, pc)
          manage_html(pc, boss_id)
        else
          pc.send_message("Wrong ID")
        end
      else
        pc.send_message("Usage: #grandboss_skip Id")
      end
    when "admin_grandboss_respawn"
      if !st.empty?
        boss_id = st.shift.to_i

        case boss_id
        when ANTHARAS
          antharas_ai.notify_event("RESPAWN_ANTHARAS", nil, pc)
          manage_html(pc, boss_id)
        when BAIUM
          baium_ai.notify_event("RESPAWN_BAIUM", nil, pc)
          manage_html(pc, boss_id)
        else
          pc.send_message("Wrong ID")
        end
      else
        pc.send_message("Usage: #grandboss_respawn Id")
      end
    when "admin_grandboss_minions"
      if !st.empty?
        boss_id = st.shift.to_i

        case boss_id
        when ANTHARAS
          antharas_ai.notify_event("DESPAWN_MINIONS", nil, pc)
        when BAIUM
          baium_ai.notify_event("DESPAWN_MINIONS", nil, pc)
        else
          pc.send_message("Wrong ID")
        end
      else
        pc.send_message("Usage: #grandboss_minions Id")
      end
    when "admin_grandboss_abort"
      if !st.empty?
        boss_id = st.shift.to_i

        case boss_id
        when ANTHARAS
          antharas_ai.notify_event("ABORT_FIGHT", nil, pc)
          manage_html(pc, boss_id)
        when BAIUM
          baium_ai.notify_event("ABORT_FIGHT", nil, pc)
          manage_html(pc, boss_id)
        else
          pc.send_message("Wrong ID")
        end
      else
        pc.send_message("Usage: #grandboss_abort Id")
      end
    else
      # [automatically added else]
    end


    true
  end

  private def manage_html(pc, boss_id)
    if {ANTHARAS, VALAKAS, BAIUM, QUEENANT, ORFEN, CORE}.includes?(boss_id)
      boss_status = GrandBossManager.get_boss_status(boss_id)
      dead_status = 0

      case boss_id
      when ANTHARAS
        boss_zone = ZoneManager.get_zone_by_id(ANTHARAS_ZONE, L2NoRestartZone)
        html_path = "data/html/admin/grandboss_antharas.htm"
      when VALAKAS
        html_path = "data/html/admin/grandboss_valakas.htm"
      when BAIUM
        boss_zone = ZoneManager.get_zone_by_id(BAIUM_ZONE, L2NoRestartZone)
        html_path = "data/html/admin/grandboss_baium.htm"
      when QUEENANT
        html_path = "data/html/admin/grandboss_queenant.htm"
      when ORFEN
        html_path = "data/html/admin/grandboss_orfen.htm"
      when CORE
        html_path = "data/html/admin/grandboss_core.htm"
      else
        # [automatically added else]
      end


      if {ANTHARAS, VALAKAS, BAIUM}.includes?(boss_id)
        dead_status = 3
        case boss_status
        when 0
          text_color = "00FF00" # Green
          text = "Alive"
        when 1
          text_color = "FFFF00" # Yellow
          text = "Waiting"
        when 2
          text_color = "FF9900" # Orange
          text = "In Fight"
        when 3
          text_color = "FF0000" # Red
          text = "Dead"
        else
          # [automatically added else]
        end

      else
        dead_status = 1
        case boss_status
        when 0
          text_color = "00FF00" # Green
          text = "Alive"
        when 1
          text_color = "FF0000" # Red
          text = "Dead"
        else
          # [automatically added else]
        end

      end

      html = NpcHtmlMessage.new(0, 1)
      html.html = HtmCache.get_htm(pc, html_path.not_nil!).not_nil!
      html["%bossStatus%"] = text
      html["%bossColor%"] = text_color

      if boss_status == dead_status
        info = GrandBossManager.get_stats_set(boss_id).not_nil!
        time = Time.from_ms(info.get_i64("respawn_time"))
        boss_respawn = time.to_s("%Y-%m-%d %H:%m:%S")

        html["%respawnTime%"] = boss_respawn
      else
        html["%respawnTime%"] = "Already respawned"
      end

      if boss_zone
        html["%playersInside%"] = boss_zone.players_inside.size
      else
        html["%playersInside%"] = "Zone not found"
      end

      pc.send_packet(html)
    else
      pc.send_message("Wrong ID")
    end
  end

  private def antharas_ai
    unless ai = QuestManager.get_quest("Antharas")
      raise "Antharas AI not found."
    end

    ai
  end

  private def baium_ai
    unless ai = QuestManager.get_quest("Baium")
      raise "Baium AI not found."
    end

    ai
  end

  def commands
    {
      "admin_grandboss",
      "admin_grandboss_skip",
      "admin_grandboss_respawn",
      "admin_grandboss_minions",
      "admin_grandboss_abort"
    }
  end
end
