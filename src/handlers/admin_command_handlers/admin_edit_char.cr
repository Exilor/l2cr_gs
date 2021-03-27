module AdminCommandHandler::AdminEditChar
  extend self
  extend AdminCommandHandler
  include Packets::Outgoing

  def use_admin_command(command, pc)
    if command == "admin_current_player"
      show_character_info(pc, pc)
    elsif command.starts_with?("admin_character_info")
      data = command.split
      if data.size > 1
        show_character_info(pc, L2World.get_player(data[1]))
      elsif pc_target = pc.target.as?(L2PcInstance)
        show_character_info(pc, pc_target)
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    elsif command.starts_with?("admin_character_list")
      list_characters(pc, 0)
    elsif command.starts_with?("admin_show_characters")
      begin
        val = command.from(22)
        page = val.to_i
        list_characters(pc, page)
      rescue e
        # Empty page number
        pc.send_message("Usage: //show_characters <page_number>")
      end
    elsif command.starts_with?("admin_find_character")
      begin
        val = command.from(21)
        find_character(pc, val)
      rescue e
        pc.send_message("Usage: //find_character <character_name>")
        list_characters(pc, 0)
      end
    elsif command.starts_with?("admin_find_ip")
      begin
        val = command.from(14)
        find_characters_per_ip(pc, val)
      rescue e
        pc.send_message("Usage: //find_ip <www.xxx.yyy.zzz>")
        list_characters(pc, 0)
      end
    elsif command.starts_with?("admin_find_account")
      begin
        val = command.from(19)
        find_characters_per_account(pc, val)
      rescue e
        pc.send_message("Usage: //find_account <player_name>")
        list_characters(pc, 0)
      end
    elsif command.starts_with?("admin_edit_character")
      data = command.split
      if data.size > 1
        edit_character(pc, data[1])
      elsif pc.target.is_a?(L2PcInstance)
        edit_character(pc, nil)
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    # Karma control commands
    elsif command == "admin_nokarma"
      set_target_karma(pc, 0)
    elsif command.starts_with?("admin_setkarma")
      begin
        val = command.from(15)
        karma = val.to_i
        set_target_karma(pc, karma)
      rescue e
        if Config.developer
          warn "Set karma error"
          warn e
        end
        pc.send_message("Usage: //setkarma <new_karma_value>")
      end
    elsif command.starts_with?("admin_setpk")
      begin
        val = command.from(12)
        pk = val.to_i
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
          player.pk_kills = pk
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(ExBrExtraUserInfo.new(player))
          player.send_message("A GM changed your PK count to #{pk}")
          pc.send_message("#{player}'s PK count changed to #{pk}")
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      rescue e
        if Config.developer
          warn "Set pk error"
          warn e
        end
        pc.send_message("Usage: //setpk <pk_count>")
      end
    elsif command.starts_with?("admin_setpvp")
      begin
        val = command.from(13)
        pvp = val.to_i
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
          player.pvp_kills = pvp
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(ExBrExtraUserInfo.new(player))
          player.send_message("A GM changed your PVP count to #{pvp}")
          pc.send_message("#{player}'s PVP count changed to #{pvp}")
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      rescue e
        if Config.developer
          warn "Set pvp error"
          warn e
        end
        pc.send_message("Usage: //setpvp <pvp_count>")
      end
    elsif command.starts_with?("admin_setfame")
      begin
        val = command.from(14)
        fame = val.to_i
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
          player.fame = fame
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(ExBrExtraUserInfo.new(player))
          player.send_message("A GM changed your Reputation points to #{fame}")
          pc.send_message("#{player}'s Fame changed to #{fame}")
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      rescue e
        if Config.developer
          warn "Set Fame error"
          warn e
        end
        pc.send_message("Usage: //setfame <new_fame_value>")
      end
    elsif command.starts_with?("admin_rec")
      begin
        val = command.from(10)
        rec_val = val.to_i
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
          player.recom_have = rec_val
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(ExBrExtraUserInfo.new(player))
          player.send_packet(ExVoteSystemInfo.new(player))
          player.send_message("A GM changed your Recommend points to #{rec_val}")
          pc.send_message("#{player}'s Recommend changed to #{rec_val}")
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      rescue e
        pc.send_message("Usage: //rec number")
      end
    elsif command.starts_with?("admin_setclass")
      begin
        val = command.from(15).strip
        class_id_val = val.to_i
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
        else
          return false
        end
        valid = ClassId.find { |class_id| class_id_val == class_id.to_i }
        if valid && player.class_id.to_i != class_id_val
          TransformData.transform_player(255, player)
          player.class_id = class_id_val
          unless player.subclass_active?
            player.base_class = class_id_val
          end
          new_class = ClassListData.get_class(player.class_id).class_name
          player.store_me
          player.send_message("A GM changed your class to #{new_class}.")
          player.untransform
          player.broadcast_user_info
          pc.target = nil
          pc.target = player
          pc.send_message("#{player} is a #{new_class}.")
        else
          pc.send_message("Usage: //setclass <valid_new_classid>")
        end
      rescue e
        pc.send_message("Usage: //setclass <valid_new_classid>")
        AdminHtml.show_admin_html(pc, "setclass/human_fighter.htm")
      end
    elsif command.starts_with?("admin_settitle")
      begin
        val = command.from(15)
        unless player = pc.target.as?(L2PcInstance)
          return false
        end
        player.title = val
        player.send_message("Your title has been changed by a GM")
        player.broadcast_title_info
      rescue e
        pc.send_message("You need to specify the new title.")
      end
    elsif command.starts_with?("admin_changename")
      begin
        val = command.from(17)
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
        else
          return false
        end
        if CharNameTable.get_id_by_name(val) > 0
          pc.send_message("Warning, player #{val} already exists")
          return false
        end
        player.name = val
        player.store_me

        pc.send_message("Changed name to #{val}")
        player.send_message("Your name has been changed by a GM.")
        player.broadcast_user_info

        if party = player.party
          # Delete party window for other party members
          party.broadcast_to_party_members(player, PartySmallWindowDeleteAll::STATIC_PACKET)
          party.members.each do |member|
            # And re-add
            if member != player
              member.send_packet(PartySmallWindowAll.new(member, party))
            end
          end
        end
        if clan = player.clan
          clan.broadcast_clan_status
        end
      rescue e
        pc.send_message("Usage: //setname new_name_for_target")
      end
    elsif command.starts_with?("admin_setsex")
      target = pc.target
      if target.is_a?(L2PcInstance)
        player = target
      else
        return false
      end
      player.appearance.sex = !player.appearance.sex
      player.send_message("Your gender has been changed by a GM")
      player.broadcast_user_info
    elsif command.starts_with?("admin_setcolor")
      begin
        val = command.from(15)
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
        else
          return false
        end
        player.appearance.name_color = "0x#{val}".to_i(16, prefix: true)
        player.send_message("Your name color has been changed by a GM")
        player.broadcast_user_info
      rescue e
        pc.send_message("You need to specify a valid new color.")
      end
    elsif command.starts_with?("admin_settcolor")
      begin
        val = command.from(16)
        target = pc.target
        if target.is_a?(L2PcInstance)
          player = target
        else
          return false
        end
        player.appearance.title_color = "0x#{val}".to_i(16, prefix: true)
        player.send_message("Your title color has been changed by a GM")
        player.broadcast_user_info
      rescue e
        pc.send_message("You need to specify a valid new color.")
      end
    elsif command.starts_with?("admin_fullfood")
      case target = pc.target
      when L2PetInstance
        target.current_feed = target.max_fed
        target.broadcast_status_update
      when L2ServitorInstance
        target.life_time_remaining = target.life_time
        target.broadcast_status_update
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    elsif command.starts_with?("admin_remove_clan_penalty")
      begin
        st = command.split
        if st.size != 3
          pc.send_message("Usage: //remove_clan_penalty join|create charname")
          return false
        end

        st.shift

        expired = st.shift.casecmp?("create")

        player_name = st.shift
        player = L2World.get_player(player_name)

        if player.nil?
          if expired
            sql = "UPDATE characters SET clan_create_expiry_time WHERE char_name=? LIMIT 1"
          else
            sql = "UPDATE characters SET clan_join_expiry_time WHERE char_name=? LIMIT 1"
          end
          begin
            GameDB.exec(sql, player_name)
          rescue e
            error e
          end
          return false # custom
        else
          # removing penalty
          if expired
            player.clan_create_expiry_time = 0
          else
            player.clan_join_expiry_time = 0
          end
        end

        pc.send_message("Clan penalty successfully removed to character: " + player.name)
      rescue e
        error e
      end
    elsif command.starts_with?("admin_find_dualbox")
      multibox = 2
      begin
        val = command.from(19)
        multibox = val.to_i
        if multibox < 1
          pc.send_message("Usage: //find_dualbox [number > 0]")
          return false
        end
      rescue e
        warn e
      end
      find_dualbox(pc, multibox)
    elsif command.starts_with?("admin_strict_find_dualbox")
      multibox = 2
      begin
        val = command.from(26)
        multibox = val.to_i
        if multibox < 1
          pc.send_message("Usage: //strict_find_dualbox [number > 0]")
          return false
        end
      rescue e
        warn e
      end
      find_dualbox_strict(pc, multibox)
    elsif command.starts_with?("admin_tracert")
      data = command.split
      if data.size > 1
        pl = L2World.get_player(data[1])
      else
        target = pc.target
        if target.is_a?(L2PcInstance)
          pl = target
        end
      end

      unless pl
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      client = pl.client
      unless client
        pc.send_message("Client is null.")
        return false
      end

      if client.detached?
        pc.send_message("Client is detached.")
        return false
      end

      trace = client.traceroute
      trace.size.times do |i|
        ip = ""
        trace[0].size.times do |o|
          ip = "#{ip}#{trace[i][o]}"
          if o != trace[0].size &- 1
            ip += "."
          end
        end
        pc.send_message("Hop#{i}: #{ip}")
      end
    elsif command.starts_with?("admin_summon_info")
      target = pc.target
      if target.is_a?(L2Summon)
        gather_summon_info(target, pc)
      else
        pc.send_message("Invalid target.")
      end
    elsif command.starts_with?("admin_unsummon")
      target = pc.target
      if target.is_a?(L2Summon)
        target.unsummon(target.owner)
      else
        pc.send_message("Usable only with Pets/Summons")
      end
    elsif command.starts_with?("admin_summon_setlvl")
      target = pc.target
      if target.is_a?(L2PetInstance)
        pet = target
        begin
          val = command.from(20)
          level = val.to_i
          oldexp = pet.stat.exp
          newexp = pet.stat.get_exp_for_level(level)
          if oldexp > newexp
            pet.stat.remove_exp(oldexp - newexp)
          elsif oldexp < newexp
            pet.stat.add_exp(newexp - oldexp)
          end
        rescue e
          warn e
        end
      else
        pc.send_message("Usable only with Pets")
      end
    elsif command.starts_with?("admin_show_pet_inv")
      begin
        val = command.from(19)
        l2id = val.to_i
        target = L2World.get_pet(l2id)
      rescue
        target = pc.target
      end

      if target.is_a?(L2PetInstance)
        pc.send_packet(GMViewItemList.new(target))
      else
        pc.send_message("Usable only with Pets")
      end

    elsif command.starts_with?("admin_partyinfo")
      begin
        val = command.from(16)
        unless target = L2World.get_player(val)
          target = pc.target
        end
      rescue
        target = pc.target
      end

      if target.is_a?(L2PcInstance)
        if target.in_party?
          gather_party_info(target, pc)
        else
          pc.send_message("Not in party.")
        end
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end

    elsif command == "admin_setnoble"
      if pc.target.nil?
        player = pc
      elsif tmp = pc.target.as?(L2PcInstance)
        player = tmp
      end

      if player
        player.noble = !player.noble?
        if player.l2id != pc.l2id
          pc.send_message("You've changed nobless status of: " + player.name)
        end
        player.send_message("GM changed your nobless status")
      end
    elsif command.starts_with?("admin_set_hp")
      data = command.split
      begin
        target = pc.target
        unless target.is_a?(L2Character)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        target.current_hp = data[1].to_f
      rescue e
        pc.send_message("Usage: //set_hp 1000")
      end
    elsif command.starts_with?("admin_set_mp")
      data = command.split
      begin
        target = pc.target
        unless target.is_a?(L2Character)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        target.current_mp = data[1].to_f
      rescue e
        warn e
        pc.send_message("Usage: //set_mp 1000")
      end
    elsif command.starts_with?("admin_set_cp")
      data = command.split
      begin
        target = pc.target
        unless target.is_a?(L2Character)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        target.current_cp = data[1].to_f
      rescue e
        pc.send_message("Usage: //set_cp 1000")
      end
    elsif command.starts_with?("admin_set_pvp_flag")
      begin
        target = pc.target
        unless target.is_a?(L2Playable)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        playable = target
        playable.update_pvp_flag((playable.pvp_flag.to_i32 &- 1).abs)
      rescue e
        pc.send_message("Usage: //set_pvp_flag")
      end
    end

    true
  end

  private def list_characters(pc, page)
    players = compared_players

    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/charlist.htm")

    fn1 = ->(i : Int32) do
      "<td align=center><a action=\"bypass -h admin_show_characters #{i}\">Page #{i &+ 1}</a></td>"
    end
    fn2 = ->(player : L2PcInstance) do
      String.build do |io|
        io << "<tr><td width=80><a action=\"bypass -h admin_character_info "
        io << player.name
        io << "\">"
        io << player.name
        io << "</a></td><td width=110>"
        ClassListData.get_class(player.class_id).client_code(io)
        io << "</td><td width=40>"
        io << player.level
        io << "</td></tr>"
      end
    end

    result = HtmlUtil.create_page(players, page, 20, fn1, fn2)

    if result.pages > 0
      html["%pages%"] = "<table width=280 cellspacing=0><tr>#{result.pager_template}</tr></table>"
    else
      html["%pages%"] = ""
    end

    html["%players%"] = result.body_template
    pc.send_packet(html)
  end

  private def show_character_info(pc, player)
    if player.nil?
      target = pc.target
      if target.is_a?(L2PcInstance)
        player = target
      else
        return
      end
    else
      pc.target = player
    end
    gather_character_info(pc, player, "charinfo.htm")
  end

  private def gather_character_info(pc, player, filename)
    ip = "N/A"

    unless player
      pc.send_message("Player is null.")
      return
    end

    client = player.client
    if client.nil?
      pc.send_message("Client is null.")
    elsif client.detached?
      pc.send_message("Client is detached.")
    else
      ip = client.connection.ip
    end

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/" + filename)
    repl["%name%"] = player.name
    repl["%level%"] = player.level
    if clan = player.clan
      repl["%clan%"] = "<a action=\"bypass -h admin_clan_info #{player.l2id}\">#{clan.name}</a>"
    else
      repl["%clan%"] = ""
    end
    repl["%xp%"] = player.exp
    repl["%sp%"] = player.sp
    repl["%class%"] = ClassListData.get_class(player.class_id).client_code
    repl["%ordinal%"] = player.class_id.to_i
    repl["%classid%"] = player.class_id
    repl["%baseclass%"] = ClassListData.get_class(player.base_class).client_code
    repl["%x%"] = player.x
    repl["%y%"] = player.y
    repl["%z%"] = player.z
    repl["%currenthp%"] = player.current_hp.to_i
    repl["%maxhp%"] = player.max_hp
    repl["%karma%"] = player.karma
    repl["%currentmp%"] = player.current_mp.to_i
    repl["%maxmp%"] = player.max_mp
    repl["%pvpflag%"] = player.pvp_flag
    repl["%currentcp%"] = player.current_cp.to_i
    repl["%maxcp%"] = player.max_cp
    repl["%pvpkills%"] = player.pvp_kills
    repl["%pkkills%"] = player.pk_kills
    repl["%currentload%"] = player.current_load
    repl["%maxload%"] = player.max_load
    repl["%percent%"] = (player.current_load.fdiv(player.max_load) * 100).round(2)
    repl["%patk%"] = player.get_p_atk(nil).to_i
    repl["%matk%"] = player.get_m_atk(nil, nil).to_i
    repl["%pdef%"] = player.get_p_def(nil).to_i
    repl["%mdef%"] = player.get_m_def(nil, nil).to_i
    repl["%accuracy%"] = player.accuracy
    repl["%evasion%"] = player.get_evasion_rate(nil)
    repl["%critical%"] = player.get_critical_hit(nil, nil)
    repl["%runspeed%"] = player.run_speed.to_i
    repl["%patkspd%"] = player.p_atk_spd
    repl["%matkspd%"] = player.m_atk_spd
    repl["%access%"] = "#{player.access_level.level} (#{player.access_level.name})"
    repl["%account%"] = player.account_name
    repl["%ip%"] = ip
    repl["%ai%"] = player.intention
    if player.instance_id > 0
      repl["%inst%"] = "<tr><td>InstanceId:</td><td><a action=\"bypass -h admin_instance_spawns #{player.instance_id}\">#{player.instance_id}</a></td></tr>"
    else
      repl["%inst%"] = ""
    end
    repl["%noblesse%"] = player.noble? ? "Yes" : "No"
    pc.send_packet(repl)
  end

  private def set_target_karma(pc, new_karma)
    unless player = pc.target.as?(L2PcInstance)
      return
    end

    if new_karma >= 0
      # for display
      old_karma = player.karma
      # update karma
      player.karma = new_karma
      # Common character information
      sm = SystemMessage.your_karma_has_been_changed_to_s1
      sm.add_int(new_karma)
      player.send_packet(sm)
      # Admin information
      pc.send_message("Successfully Changed karma for #{player} from #{old_karma} to #{new_karma}.")
      debug { "[SET KARMA] [GM] #{pc} Changed karma for #{player} from #{old_karma} to #{new_karma}." }
    else
      # tell admin of mistake
      pc.send_message("You must enter a value for karma greater than or equal to 0.")
      debug { "[SET KARMA] ERROR: [GM] #{pc} entered an incorrect value for new karma: #{new_karma} for #{player}." }
    end
  end

  private def edit_character(pc, target_name)
    if target_name
      target = L2World.get_player(target_name)
    else
      target = pc.target
    end

    if target.is_a?(L2PcInstance)
      gather_character_info(pc, target, "charedit.htm")
    end
  end

  private def find_character(pc, to_find)
    chars_found = 0
    name
    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/charfind.htm")

    rep_msg = String::Builder.new

    compared_players.each do |player|
      name = player.name
      if name.downcase.includes?(to_find.downcase)
        chars_found = chars_found &+ 1
        rep_msg << "<tr><td width=80><a action=\"bypass -h admin_character_info "
        rep_msg << name
        rep_msg << "\">"
        rep_msg << name
        rep_msg << "</a></td><td width=110>"
        rep_msg << ClassListData.get_class(player.class_id).client_code
        rep_msg << "</td><td width=40>"
        rep_msg << player.level
        rep_msg << "</td></tr>"
      end
      if chars_found > 20
        break
      end
    end
    repl["%results%"] = rep_msg

    if chars_found == 0
      rep_msg2 = "s. Please try again."
    elsif chars_found > 20
      repl["%number%"] = " more than 20"
      rep_msg2 = "s.<br>Please refine your search to see all of the results."
    elsif chars_found == 1
      rep_msg2 = "."
    else
      rep_msg2 = "s."
    end

    repl["%number%"] = chars_found
    repl["%end%"] = rep_msg2
    pc.send_packet(repl)
  end

  private def find_characters_per_ip(pc, ip_address)
    find_disconnected = false

    if ip_address == "disconnected"
      find_disconnected = true
    else
      unless /^(?:(?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2(?:[0-4][0-9]|5[0-5]))\\.){3}(?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2(?:[0-4][0-9]|5[0-5]))$/ == ip_address
        raise "Malformed IPv4 number '#{ip_address}'"
      end
    end

    chars_found = 0
    ip = "0.0.0.0"
    rep_msg = String::Builder.new
    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/ipfind.htm")
    compared_players.each do |player|
      unless client = player.client
        next
      end

      if (client.detached?)
        if (!find_disconnected)
          next
        end
      else
        if (find_disconnected)
          next
        end

        ip = client.connection.ip
        if ip != ip_address
          next
        end
      end

      name = player.name
      chars_found = chars_found &+ 1
      rep_msg << "<tr><td width=80><a action=\"bypass -h admin_character_info "
      rep_msg << name
      rep_msg << "\">"
      rep_msg << name
      rep_msg << "</a></td><td width=110>"
      rep_msg << ClassListData.get_class(player.class_id).client_code
      rep_msg << "</td><td width=40>"
      rep_msg << player.level
      rep_msg << "</td></tr>"

      if chars_found > 20
        break
      end
    end
    repl["%results%"] = rep_msg

    if chars_found == 0
      rep_msg2 = "s. Maybe they got d/c? :)"
    elsif chars_found > 20
      repl["%number%"] = " more than #{chars_found}"
      rep_msg2 = "s.<br>In order to avoid you a client crash I won't <br1>display results beyond the 20th character."
    elsif chars_found == 1
      rep_msg2 = "."
    else
      rep_msg2 = "s."
    end
    repl["%ip%"] = ip_address
    repl["%number%"] = chars_found
    repl["%end%"] = rep_msg2
    pc.send_packet(repl)
  end

  private def find_characters_per_account(pc, char_name)
    unless player = L2World.get_player(char_name)
      raise "Player doesn't exist"
    end

    chars = player.account_chars
    rep_msg = String.build(chars.size &* 20) do |io|
      chars.each_value { |name| io << name << "<br1>" }
    end

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/accountinfo.htm")
    repl["%account%"] = player.account_name
    repl["%player%"] = char_name
    repl["%characters%"] = rep_msg
    pc.send_packet(repl)
  end

  private def find_dualbox(pc, multibox)
    ip_map = {} of String => Array(L2PcInstance)
    ip = "0.0.0.0"
    dualbox_ips = {} of String => Int32

    compared_players.each do |player|
      client = player.client
      if client.nil? || client.detached?
        next
      end

      ip = client.connection.ip
      if ip_map[ip]?.nil?
        ip_map[ip] = [] of L2PcInstance
      end
      ip_map[ip] << player

      if ip_map[ip].size >= multibox
        count = dualbox_ips[ip]?
        if count.nil?
          dualbox_ips[ip] = multibox
        else
          dualbox_ips[ip] = count &+ 1
        end
      end
    end

    keys = dualbox_ips.keys
    keys.sort_by! { |s| dualbox_ips[s] }
    keys.reverse!

    results = String.build do |io|
      keys.each do |dbx_ip|
        io << "<a action=\"bypass -h admin_find_ip "
        io << dbx_ip
        io << "\">"
        io << dbx_ip
        io << " ("
        io << dualbox_ips[dbx_ip]
        io << ")</a><br1>"
      end
    end

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/dualbox.htm")
    repl["%multibox%"] = multibox
    repl["%results%"] = results
    repl["%strict%"] = ""
    pc.send_packet(repl)
  end

  private def find_dualbox_strict(pc, multibox)
    ip_map = {} of IpPack => Array(L2PcInstance)
    dualbox_ips = {} of IpPack => Int32

    compared_players.each do |player|
      client = player.client
      if client.nil? || client.detached?
        next
      end

      pack = IpPack.new(client.connection.ip, client.traceroute)
      (ip_map[pack] ||= [] of L2PcInstance) << player

      if ip_map[pack].size >= multibox
        count = dualbox_ips[pack]?
        if count.nil?
          dualbox_ips[pack] = multibox
        else
          dualbox_ips[pack] = count &+ 1
        end
      end
    end

    keys = dualbox_ips.keys
    keys.sort_by! { |s| dualbox_ips[s] }
    keys.reverse!

    results = String.build do |io|
      keys.each do |dbx_ip|
        io << "<a action=\"bypass -h admin_find_ip "
        io << dbx_ip.ip
        io << "\">"
        io << dbx_ip.ip
        io << " ("
        io << dualbox_ips[dbx_ip]
        io << ")</a><br1>"
      end
    end

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/dualbox.htm")
    repl["%multibox%"] = multibox
    repl["%results%"] = results
    repl["%strict%"] = "strict_"
    pc.send_packet(repl)
  end

  private def gather_summon_info(target, pc)
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/petinfo.htm")
    name = target.name
    html["%name%"] = name || "N/A"
    html["%level%"] = target.level
    html["%exp%"] = target.stat.exp
    owner = target.acting_player.name
    html["%owner%"] = " <a action=\"bypass -h admin_character_info #{owner}\">#{owner}</a>"
    html["%class%"] = target.class.simple_name
    html["%ai%"] = target.ai? ? target.ai.intention.to_s : "NULL"
    html["%hp%"] = "#{target.status.current_hp.to_i}/#{target.stat.max_hp}"
    html["%mp%"] = "#{target.status.current_mp.to_i}/#{target.stat.max_mp}"
    html["%karma%"] = target.karma
    html["%race%"] = target.template.race.to_s
    if target.is_a?(L2PetInstance)
      l2id = target.acting_player.l2id
      html["%inv%"] = " <a action=\"bypass admin_show_pet_inv #{l2id}\">view</a>"
    else
      html["%inv%"] = "none"
    end
    if target.is_a?(L2PetInstance)
      html["%food%"] = "#{target.current_feed}/#{target.pet_level_data.pet_max_feed}"
      html["%load%"] = "#{target.inventory.total_weight}/#{target.max_load}"
    else
      html["%food%"] = "N/A"
      html["%load%"] = "N/A"
    end
    pc.send_packet(html)
  end

  private def gather_party_info(target, pc)
    color = true
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/partyinfo.htm")
    text = String.build(400) do |io|
      target.party.not_nil!.members.each do |member|
        if color
          io << "<tr><td><table width=270 border=0 bgcolor=131210 cellpadding=2><tr><td width=30 align=right>"
        else
          io << "<tr><td><table width=270 border=0 cellpadding=2><tr><td width=30 align=right>"
        end
        io << member.level
        io << "</td><td width=130><a action=\"bypass -h admin_character_info "
        io << member.name
        io << "\">"
        io << member.name
        io << "</a>"
        io << "</td><td width=110 align=right>"
        io << member.class_id.to_s
        io << "</td></tr></table></td></tr>"
        color = !color
      end
    end
    html["%player%"] = target.name
    html["%party%"] = text
    pc.send_packet(html)
  end

  private def compared_players
    L2World.players.to_a.tap &.sort_by! &.uptime
  end

  private record IpPack, ip : String, tracert : Slice(Bytes)

  def commands : Enumerable(String)
    {
      "admin_edit_character",
      "admin_current_player",
      "admin_nokarma", # remove karma from selected char
      "admin_setkarma", # sets karma of target char. //setkarma <karma>
      "admin_setfame", # sets fame of target char. //setfame <fame>
      "admin_character_list", # same as character_info
      "admin_character_info", # given a player name, displays an information window
      "admin_show_characters", # list of characters
      "admin_find_character", # find a player by his name or a part of it (case-insensitive)
      "admin_find_ip", # find all the player connections from a given IPv4 number
      "admin_find_account", # list all the characters from an account (useful for GMs w/o DB access)
      "admin_find_dualbox", # list all the IPs with more than 1 char logged in (dualbox)
      "admin_strict_find_dualbox",
      "admin_tracert",
      "admin_rec", # gives recommendation points
      "admin_settitle", # changes char title
      "admin_changename", # changes char name
      "admin_setsex", # changes characters' sex
      "admin_setcolor", # change charnames' color display
      "admin_settcolor", # change char title color
      "admin_setclass", # changes chars' classId
      "admin_setpk", # changes PK count
      "admin_setpvp", # changes PVP count
      "admin_set_pvp_flag",
      "admin_fullfood", # fills up a pet's food bar
      "admin_remove_clan_penalty", # removes clan penalties
      "admin_summon_info", # displays an information window about target summon
      "admin_unsummon",
      "admin_summon_setlvl",
      "admin_show_pet_inv",
      "admin_partyinfo",
      "admin_setnoble",
      "admin_set_hp",
      "admin_set_mp",
      "admin_set_cp"
    }
  end
end
