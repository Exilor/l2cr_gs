module AdminCommandHandler::AdminCHSiege
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    split = command.split

    if Config.alt_dev_no_quests
      pc.send_message("AltDevNoQuests = true; Clan Hall Sieges are disabled")
      return false
    end

    if split.size < 2
      pc.send_message("You have to specify the hall id at least")
      return false
    end

    unless hall = get_hall(split[1], pc)
      pc.send_message("Couldn't find he desired siegable hall (#{split[1]})")
      return false
    end

    if hall.siege.nil?
      pc.send_message("The given hall dont have any attached siege")
      return false
    end

    if split[0] == commands[1]
      if hall.in_siege?
        pc.send_message("The requested clan hall is alredy in siege")
      else
        if owner = ClanTable.get_clan(hall.owner_id)
          hall.free
          owner.hideout_id = 0
          hall.add_attacker(owner)
        end
        hall.siege.start_siege
      end
    elsif split[0] == commands[2]
      if !hall.in_siege?
        pc.send_message("The requested clan hall isnt in siege")
      else
        hall.siege.end_siege
      end
    elsif split[0] == commands[3]
      if !hall.registering?
        pc.send_message("Cannot change siege date while hall is in siege")
      elsif split.size < 3
        pc.send_message("The date format is incorrect. Try again.")
      else
        raw_date = split[2].split(";")
        if raw_date.size < 2
          pc.send_message("You have to specify this format DD-MM-YYYY;HH:MM")
        else
          day = raw_date[0].split("-")
          hour = raw_date[1].split(":")
          if day.size < 3 || hour.size < 2
            pc.send_message("Incomplete day, hour or both")
          else
            d = day[0].to_i
            month = day[1].to_i &- 1
            year = day[2].to_i
            h = hour[0].to_i
            min = hour[1].to_i
            if (month == 2 && d > 28) || d > 31 || d <= 0 || month <= 0 || month > 12 || year < Calendar.new.year
              pc.send_message("Wrong day/month/year given")
            elsif h <= 0 || h > 24 || min < 0 || min >= 60
              pc.send_message("Wrong hour/minutes given")
            else
              c = Calendar.new
              c.year = year
              c.month = month
              c.day = d
              c.hour = h
              c.minute = min
              c.second = 0

              if c.ms > Time.ms
                pc.send_message("#{hall.name} siege: #{c.time}")
                hall.next_siege_date = c.ms
                hall.siege.update_siege
                hall.update_db
              else
                pc.send_message("The given time is in the past")
              end
            end
          end
        end
      end
    elsif split[0] == commands[4]
      if hall.in_siege?
        pc.send_message("The clan hall is in siege, cannot add attackers now.")
        return false
      end

      if split.size < 3
        raw_target = pc.target
        if raw_target.nil?
          pc.send_message("You must target a clan member of the attacker")
        elsif !raw_target.is_a?(L2PcInstance)
          pc.send_message("You must target a player with clan")
        elsif (target = raw_target).clan.nil?
          pc.send_message("Your target does not have any clan")
        elsif hall.siege.attacker?(target.clan)
          pc.send_message("Your target's clan is alredy participating")
        else
          attacker = target.clan
        end
      else
        raw_clan = ClanTable.get_clan_by_name(split[2])
        if raw_clan.nil?
          pc.send_message("The given clan does not exist")
        elsif hall.siege.attacker?(raw_clan)
          pc.send_message("The given clan is alredy participating")
        else
          attacker = raw_clan
        end
      end

      if attacker
        hall.add_attacker(attacker)
      end
    elsif split[0] == commands[5]
      if hall.in_siege?
        pc.send_message("The clan hall is in siege, cannot remove attackers now.")
        return false
      end

      if split.size < 3
        raw_target = pc.target
        if raw_target.nil?
          pc.send_message("You must target a clan member of the attacker")
        elsif !raw_target.is_a?(L2PcInstance)
          pc.send_message("You must target a player with clan")
        elsif (target = raw_target).clan.nil?
          pc.send_message("Your target does not have any clan")
        elsif !hall.siege.attacker?(target.clan)
          pc.send_message("Your target's clan is not participating")
        else
          hall.remove_attacker(target.clan.not_nil!)
        end
      else
        raw_clan = ClanTable.get_clan_by_name(split[2])
        if raw_clan.nil?
          pc.send_message("The given clan does not exist")
        elsif !hall.siege.attacker?(raw_clan)
          pc.send_message("The given clan is not participating")
        else
          hall.remove_attacker(raw_clan)
        end
      end
    elsif split[0] == commands[6]
      if hall.in_siege?
        pc.send_message("The requested hall is in siege right now, cannot clear attacker list")
      else
        hall.siege.attackers.clear
      end
    elsif split[0] == commands[7]
      pc.send_packet(SiegeInfo.new(hall))
    elsif split[0] == commands[8]
      siegable = hall.siege
      siegable.cancel_siege_task
      case hall.siege_status
      when SiegeStatus::REGISTERING
        siegable.prepare_owner
      when SiegeStatus::WAITING_BATTLE
        siegable.start_siege
      when SiegeStatus::RUNNING
        siegable.end_siege
      else
        # [automatically added else]
      end

    end

    send_siegable_hall_page(pc, split[1], hall)

    false
  end

  private def get_hall(id, gm) : SiegableHall?
    ch = id.to_i
    if ch == 0
      gm.send_message("Wrong clan hall id, unparseable id")
      return
    end

    unless hall = ClanHallSiegeManager.get_siegable_hall(ch)
      gm.send_message("Couldn't find the clan hall.")
    end

    hall
  end

  private def send_siegable_hall_page(pc, hall_id, hall)
    msg = NpcHtmlMessage.new
    msg.set_file(nil, "data/html/admin/siegablehall.htm")
    msg["%clanhallId%"] = hall_id
    msg["%clanhallName%"] = hall.name
    if hall.owner_id > 0
      if owner = ClanTable.get_clan(hall.owner_id)
        msg["%clanhallOwner%"] = owner.name
      else
        msg["%clanhallOwner%"] = "No Owner"
      end
    else
      msg["%clanhallOwner%"] = "No Owner"
    end
    pc.send_packet(msg)
  end

  def commands
    {
      "admin_chsiege_siegablehall",
      "admin_chsiege_start_siege",
      "admin_chsiege_endsSiege",
      "admin_chsiege_setSiegeDate",
      "admin_chsiege_addAttacker",
      "admin_chsiege_removeAttacker",
      "admin_chsiege_clearAttackers",
      "admin_chsiege_listAttackers",
      "admin_chsiege_forwardSiege"
    }
  end
end
