module AdminCommandHandler::AdminPunishment
  extend self
  extend AdminCommandHandler
  include Packets::Outgoing

  private DATE_FORMAT = "%Y.%m.%d %H:%M:%S"

  def use_admin_command(command, pc)
    st = command.split
    if st.empty?
      return false
    end

    cmd = st.shift
    case cmd
    when "admin_punishment"
      if st.empty?
        if content = HtmCache.get_htm(pc, "data/html/admin/punishment.htm")
          content = content.gsub("%punishments%", PunishmentType.values.join(';'))
          content = content.gsub("%affects%", PunishmentAffect.values.join(';'))
          pc.send_packet(NpcHtmlMessage.new(0, 1, content))
        else
          warn "data/html/admin/punishment.htm is missing"
        end
      else
        subcmd = st.shift
        case subcmd
        when "info"
          key = st.shift?
          af = st.shift?
          name = key

          unless key && af
            pc.send_message("Not enough data specified")
            return true
          end
          unless affect = PunishmentAffect.parse?(af)
            pc.send_message("Incorrect value specified for affect type")
            return true
          end

          # Swap the name of the character with it's id.
          if affect.character?
            key = find_char_id(key)
          end

          if content = HtmCache.get_htm(pc, "data/html/admin/punishment-info.htm")
            sb = String.build do |io|
              PunishmentType.each do |type|
                if PunishmentManager.has_punishment?(key, affect, type)
                  expiration = PunishmentManager.get_punishment_expiration(key, affect, type)
                  if expiration > 0
                    expire = Time.from_ms(expiration).to_s(DATE_FORMAT)
                  else
                    expire = "never"
                  end
                  io << "<tr><td><font color=\"LEVEL\">"
                  io << type
                  io << "</font></td><td>"
                  io << expire
                  io << "</td><td><a action=\"bypass -h admin_punishment_remove "
                  io << name
                  io << ' '
                  io << affect
                  io << ' '
                  io << type
                  io << "\">Remove</a></td></tr>"
                end
              end
            end

            content = content.gsub("%player_name%", name)
            content = content.gsub("%punishments%", sb)
            content = content.gsub("%affects%", PunishmentAffect.values.join(';'))
            content = content.gsub("%affect_type%", affect.to_s)
            pc.send_packet(NpcHtmlMessage.new(0, 1, content))
          else
            warn "data/html/admin/punishment-info.htm is missing"
          end
        when "player"
          unless st.empty?
            pc_name = st.shift
            if pc_name.empty? && !pc.target.is_a?(L2PcInstance)
              return use_admin_command("admin_punishment", pc)
            end
            target = L2World.get_player(pc_name)
          end

          target ||= pc.target.try &.acting_player

          unless target
            pc.send_message("You must target a player")
            return true
          end

          if content = HtmCache.get_htm(pc, "data/html/admin/punishment-player.htm")
            content = content.gsub("%player_name%", target.name)
            content = content.gsub("%punishments%", PunishmentType.values.join(';'))
            content = content.gsub("%acc%", target.account_name)
            content = content.gsub("%char%", target.name)
            content = content.gsub("%ip%", target.ip_address)
            pc.send_packet(NpcHtmlMessage.new(0, 1, content))
          else
            warn "data/html/admin/punishment-player.htm is missing"
          end
        end

      end
    when "admin_punishment_add"
      # Add new punishment
      key = st.shift?
      af = st.shift?
      t = st.shift?
      exp = st.shift?
      reason = st.shift?

      # Let's grab the other part of the reason if there is..
      if reason
        until st.empty?
          reason += " " + st.shift
        end

        unless reason.empty?
          reason = reason.gsub("\$", "\\\\\$")
          reason = reason.gsub("\r\n", "<br1>")
          reason = reason.sub("<", "&lt;")
          reason = reason.sub(">", "&gt;")
        end
      end

      name = key

      unless key && af && t && exp && reason
        pc.send_message("Please fill all the fields")
        return true
      end

      if !exp.number? && exp != "-1"
        pc.send_message("Incorrect value specified for expiration time")
      end

      expiration_time = exp.to_i64
      if expiration_time > 0
        expiration_time = Time.ms + (expiration_time &* 60 &* 1000)
      end

      affect = PunishmentAffect.parse?(af)
      type = PunishmentType.parse?(t)
      unless affect && type
        pc.send_message("Incorrect value specified for affect/punishment type")
        return true
      end

      if affect.character?
        key = find_char_id(key)
      elsif affect.ip?
        # TODO: check the ip
      end

      if PunishmentManager.has_punishment?(key, affect, type)
        pc.send_message("Target is already affected by that punishment.")
      end

      PunishmentManager.start_punishment(PunishmentTask.new(key, affect, type, expiration_time, reason, pc.name))
      pc.send_message("Punishment #{type} have been applied to: #{affect} #{name}")
      GMAudit.log(pc, cmd, affect.to_s, name)
      return use_admin_command("admin_punishment info #{name} #{affect}", pc)
    when "admin_punishment_remove"
      key = st.shift?
      af = st.shift?
      t = st.shift?
      name = key

      unless key && af && t
        pc.send_message("Not enough data specified")
        return true
      end

      affect = PunishmentAffect.parse?(af)
      type = PunishmentType.parse?(t)
      unless affect && type
        pc.send_message("Incorrect value specified for affect/punishment type")
        return true
      end

      if affect.character?
        key = find_char_id(key)
      end

      unless PunishmentManager.has_punishment?(key, affect, type)
        pc.send_message("Target is not affected by that punishment")
      end

      PunishmentManager.stop_punishment(key, affect, type)
      pc.send_message("Punishment #{type} has been lifted from: #{affect} #{name}")
      GMAudit.log(pc, cmd, affect.to_s, name)
      return use_admin_command("admin_punishment info #{name} #{affect}", pc)
    when "admin_ban_char"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_add %s %s %s %s %s", st.shift, PunishmentAffect::CHARACTER, PunishmentType::BAN, 0, "Banned by admin"), pc)
      end
    when "admin_unban_char"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_remove %s %s %s", st.shift, PunishmentAffect::CHARACTER, PunishmentType::BAN), pc)
      end
    when "admin_ban_acc"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_add %s %s %s %s %s", st.shift, PunishmentAffect::ACCOUNT, PunishmentType::BAN, 0, "Banned by admin"), pc)
      end
    when "admin_unban_acc"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_remove %s %s %s", st.shift, PunishmentAffect::ACCOUNT, PunishmentType::BAN), pc)
      end
    when "admin_ban_chat"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_add %s %s %s %s %s", st.shift, PunishmentAffect::CHARACTER, PunishmentType::CHAT_BAN, 0, "Chat banned by admin"), pc)
      end
    when "admin_unban_chat"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_remove %s %s %s", st.shift, PunishmentAffect::CHARACTER, PunishmentType::CHAT_BAN), pc)
      end
    when "admin_jail"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_add %s %s %s %s %s", st.shift, PunishmentAffect::CHARACTER, PunishmentType::JAIL, 0, "Jailed by admin"), pc)
      end
    when "admin_unjail"
      unless st.empty?
        return use_admin_command(sprintf("admin_punishment_remove %s %s %s", st.shift, PunishmentAffect::CHARACTER, PunishmentType::JAIL), pc)
      end
    end

    true
  end

  private def find_char_id(key)
    char_id = CharNameTable.get_id_by_name(key)
    if char_id > 0
      return char_id.to_s
    end

    key
  end

  def commands : Enumerable(String)
    {
      "admin_punishment",
      "admin_punishment_add",
      "admin_punishment_remove",
      "admin_ban_acc",
      "admin_unban_acc",
      "admin_ban_chat",
      "admin_unban_chat",
      "admin_ban_char",
      "admin_unban_char",
      "admin_jail",
      "admin_unjail"
    }
  end
end
