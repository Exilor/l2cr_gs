module AdminCommandHandler::AdminSiege
  extend self
  extend AdminCommandHandler

  private ADMIN_COMMANDS = {
    # Castle commands
    "admin_siege",
    "admin_add_attacker",
    "admin_add_defender",
    "admin_add_guard",
    "admin_list_siege_clans",
    "admin_clear_siege_list",
    "admin_move_defenders",
    "admin_spawn_doors",
    "admin_endsiege",
    "admin_startsiege",
    "admin_setsiegetime",
    "admin_setcastle",
    "admin_removecastle",
    # Clan hall commands
    "admin_clanhall",
    "admin_clanhallset",
    "admin_clanhalldel",
    "admin_clanhallopendoors",
    "admin_clanhallclosedoors",
    "admin_clanhallteleportself"
  }

  def use_admin_command(command, pc)
    st = command.split
    command = st.shift

    # Get castle
    if !st.empty?
      player = pc.target.as?(L2PcInstance)
      val = st.shift

      if command.starts_with?("admin_clanhall")
        if val.num?
          clanhall = ClanHallManager.get_clan_hall_by_id(val.to_i).not_nil!
          case command
          when "admin_clanhallset"
            unless player && (clan = player.clan)
              pc.send_packet(SystemMessageId::INCORRECT_TARGET)
              return false
            end

            if clanhall.owner_id > 0
              pc.send_message("This Clan Hall is not free")
              return false
            end

            if clan.hideout_id > 0
              pc.send_message("You have already a Clan Hall")
              return false
            end

            if clanhall.siegable_hall?
              clanhall.owner = clan
              clan.hideout_id = clanhall.id
            else
              ClanHallManager.set_owner(clanhall.id, clan)
              if auction = AuctionManager.get_auction(clanhall.id)
                auction.delete_auction_from_db
              end
            end
          when "admin_clanhalldel"
            if clanhall.siegable_hall?
              old_owner = clanhall.owner_id
              if old_owner > 0
                clanhall.free

                if clan = ClanTable.get_clan(old_owner)
                  clan.hideout_id = 0
                  clan.broadcast_clan_status
                end
              end
            else
              if ClanHallManager.free?(clanhall.id)
                pc.send_message("This Clan Hall is already free")
              else
                ClanHallManager.set_free(clanhall.id)
                AuctionManager.init_npc(clanhall.id)
              end
            end
          when "admin_clanhallopendoors"
            clanhall.open_close_doors(true)
          when "admin_clanhallclosedoors"
            clanhall.open_close_doors(false)
          when "admin_clanhallteleportself"
            if zone = clanhall.zone?
              pc.tele_to_location(zone.spawn_loc, true)
            end
          else
            if clanhall.siegable_hall?
              show_siegable_hall_page(pc, clanhall.as(SiegableHall))
            else
              show_clan_hall_page(pc, clanhall)
            end
          end
        end
      else
        castle = CastleManager.get_castle(val).not_nil!
        case command
        when "admin_add_attacker"
          if player
            castle.siege.register_attacker(player, true)
          else
            pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          end
        when "admin_add_defender"
          if player
            castle.siege.register_defender(player, true)
          else
            pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          end
        when "admin_add_guard"
          if (val = st.shift?) && val.num?
            castle.siege.siege_guard_manager.add_siege_guard(pc, val.to_i)
          end
          # If doesn't have more tokens or token is not a number.
          pc.send_message("Usage: #add_guard castle npc_id")
        when "admin_clear_siege_list"
          castle.siege.clear_siege_clan
        when "admin_endsiege"
          castle.siege.end_siege
        when "admin_list_siege_clans"
          castle.siege.list_register_clan(pc)
        when "admin_move_defenders"
          pc.send_message("Not implemented yet.")
        when "admin_setcastle"
          if clan = player.try &.clan
            castle.owner = clan
          else
            pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          end
        when "admin_removecastle"
          if clan = ClanTable.get_clan(castle.owner_id)
            castle.remove_owner(clan)
          else
            pc.send_message("Unable to remove castle.")
          end
        when "admin_setsiegetime"
          unless st.empty?
            # cal = Calendar.new
            # cal.ms = castle.siege_date.ms
            cal = castle.siege_date.dup

            val = st.shift

            if val == "month"
              month = cal.month + st.shift.to_i
              if 1 > month || 12 < month
                pc.send_message("Unable to change Siege Date - Incorrect month value only #{1}-#{12} is accepted")
                return false
              end
              cal.month = month
            elsif val == "day"
              day = st.shift.to_i
              if 1 > day || 31 < day
                pc.send_message("Unable to change Siege Date - Incorrect day value only #{1}-#{31} is accepted")
                return false
              end
              cal.day = day
            elsif val == "hour"
              hour = st.shift.to_i
              if 0 > hour || 23 < hour
                pc.send_message("Unable to change Siege Date - Incorrect hour value only #{0}-#{23} is accepted")
                return false
              end
              cal.hour = hour
            elsif val == "min"
              min = st.shift.to_i
              if 0 > min || 59 < min
                pc.send_message("Unable to change Siege Date - Incorrect minute value only #{0}-#{59} is accepted")
                return false
              end
              cal.minute = min
            end

            if cal.ms < Time.ms
              pc.send_message("Unable to change Siege Date")
            elsif cal.ms != castle.siege_date.ms
              castle.siege_date.ms = cal.ms
              castle.siege.save_siege_date
              pc.send_message("Castle siege time for castle #{castle.name} has been changed.")
            end
          end
          show_siege_time_page(pc, castle)
        when "admin_spawn_doors"
          castle.spawn_door
        when "admin_startsiege"
          castle.siege.start_siege
        else
          show_siege_page(pc, castle.name)
        end
      end
    else
      show_castle_select_page(pc)
    end

    true
  end

  private def show_castle_select_page(pc)
    i = 0
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/castles.htm")
    list = String::Builder.new
    CastleManager.castles.each do |castle|
      name = castle.name
      list << "<td fixwidth=90><a action=\"bypass -h admin_siege "
      list << name
      list << "\">"
      list << name
      list << "</a></td>"
      i &+= 1
      if i > 2
        list << "</tr><tr>"
        i = 0
      end
    end
    reply["%castles%"] = list
    list = String::Builder.new
    i = 0
    ClanHallSiegeManager.conquerable_halls.each_value do |hall|
      list << "<td fixwidth=90><a action=\"bypass -h admin_chsiege_siegablehall "
      list << hall.id
      list << "\">"
      list << hall.name
      list << "</a></td>"
      i &+= 1
      if i > 1
        list << "</tr><tr>"
        i = 0
      end
    end
    reply["%siegableHalls%"] = list
    list = String::Builder.new
    i = 0
    ClanHallManager.clan_halls.each_value do |clanhall|
      list << "<td fixwidth=134><a action=\"bypass -h admin_clanhall "
      list << clanhall.id
      list << "\">"
      list << clanhall.name
      list << "</a></td>"
      i &+= 1
      if i > 1
        list << "</tr><tr>"
        i = 0
      end
    end
    reply["%clanhalls%"] = list
    list = String::Builder.new
    i = 0
    ClanHallManager.free_clan_halls.each_value do |clanhall|
      list << "<td fixwidth=134><a action=\"bypass -h admin_clanhall "
      list << clanhall.id
      list << "\">"
      list << clanhall.name
      list << "</a></td>"
      i &+= 1
      if i > 1
        list << "</tr><tr>"
        i = 0
      end
    end
    reply["%freeclanhalls%"] = list
    pc.send_packet(reply)
  end

  private def show_siege_page(pc, castle_name)
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/castle.htm")
    reply["%castleName%"] = castle_name
    pc.send_packet(reply)
  end

  private def show_siege_time_page(pc, castle)
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/castlesiegetime.htm")
    reply["%castleName%"] = castle.name
    reply["%time%"] = castle.siege_date.time.to_s
    new_day = Calendar.new
    is_sunday = false
    if new_day.sunday?
      is_sunday = true
    else
      new_day.day_of_week = Calendar::SATURDAY
    end

    unless SevenSigns.instance.date_in_seal_valid_period?(new_day)
      new_day.add(:WEEK, 1)
    end

    if is_sunday
      reply["%sundaylink%"] = new_day.day_of_year
      reply["%sunday%"] = "#{new_day.month}/#{new_day.day}"
      new_day.add(:DAY, 13)
      reply["%saturdaylink%"] = new_day.day_of_year
      reply["%saturday%"] = "#{new_day.month}/#{new_day.day}"
    else
      reply["%saturdaylink%"] = new_day.day_of_year
      reply["%saturday%"] = "#{new_day.month}/#{new_day.day}"
      new_day.add(:DAY, 1)
      reply["%sundaylink%"] = new_day.day_of_year
      reply["%sunday%"] = "#{new_day.month}/#{new_day.day}"
    end
    pc.send_packet(reply)
  end

  private def show_clan_hall_page(pc, clanhall)
    reply = NpcHtmlMessage.new
    reply.set_file(pc, "data/html/admin/clanhall.htm")
    reply["%clanhallName%"] = clanhall.name
    reply["%clanhallId%"] = clanhall.id
    owner = ClanTable.get_clan(clanhall.owner_id)
    reply["%clanhallOwner%"] = owner ? owner.name : "None"
    pc.send_packet(reply)
  end

  private def show_siegable_hall_page(pc, hall)
    msg = NpcHtmlMessage.new
    msg.set_file(nil, "data/html/admin/siegablehall.htm")
    msg["%clanhallId%"] = hall.id
    msg["%clanhallName%"] = hall.name
    if hall.owner_id > 0
      owner = ClanTable.get_clan(hall.owner_id)
      msg["%clanhallOwner%"] = owner ? owner.name : "No owner"
    else
      msg["%clanhallOwner%"] = "No Owner"
    end
    pc.send_packet(msg)
  end

  def commands
    ADMIN_COMMANDS
  end
end
