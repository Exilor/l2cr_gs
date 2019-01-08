module AdminCommandHandler::AdminEditChar
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if (command.equals("admin_current_player"))
      show_character_info(pc, pc)
    elsif (command.starts_with?("admin_character_info"))
      data = command.split(' ')
      if ((data.length > 1))
        show_character_info(pc, L2World.get_player(data[1]))
      elsif (pc.target.is_a?(L2PcInstance)
        show_character_info(pc, pc.target.acting_player)
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    elsif (command.starts_with?("admin_character_list"))
      list_characters(pc, 0)
    elsif (command.starts_with?("admin_show_characters"))
      begin
        val = command.substring(22)
        page = val.to_i
        list_characters(pc, page)
      end
      rescue e
        # Case of empty page number
        pc.send_message("Usage: //show_characters <page_number>")
      end
    elsif (command.starts_with?("admin_find_character"))
      begin
        val = command.substring(21)
        findCharacter(pc, val)
      end
      rescue e
        pc.send_message("Usage: //find_character <character_name>")
        list_characters(pc, 0)
      end
    elsif (command.starts_with?("admin_find_ip"))
      begin
        val = command.substring(14)
        find_characters_per_ip(pc, val)
      end
      rescue e
        pc.send_message("Usage: //find_ip <www.xxx.yyy.zzz>")
        list_characters(pc, 0)
      end
    elsif (command.starts_with?("admin_find_account"))
      begin
        val = command.substring(19)
        find_characters_per_account(pc, val)
      end
      rescue e
        pc.send_message("Usage: //find_account <player_name>")
        list_characters(pc, 0)
      end
    elsif (command.starts_with?("admin_edit_character"))
      data = command.split(' ')
      if ((data.length > 1))
        edit_character(pc, data[1])
      elsif (pc.target.is_a?(L2PcInstance)
        edit_character(pc, null)
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    end
    # Karma control commands
    elsif (command.equals("admin_nokarma"))
      target = arma(pc, 0
    elsif (command.starts_with?("admin_setkarma"))
      begin
        val = command.substring(15)
        karma = val.to_i
        target = arma(pc, karma
      end
      rescue e
        if (Config.developer)
          warn "Set karma error: " + e
        end
        pc.send_message("Usage: //setkarma <new_karma_value>")
      end
    elsif (command.starts_with?("admin_setpk"))
      begin
        val = command.substring(12)
        pk = val.to_i
        L2Object target = pc.target
        if (target.is_a?(L2PcInstance)
          L2PcInstance player = (L2PcInstance) target
          player.pk_kills = pk
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(new ExBrExtraUserInfo(player))
          player.send_message("A GM changed your PK count to " + pk)
          pc.send_message(player.name + "'s PK count changed to " + pk)
        end
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      end
      rescue e
        if (Config.developer)
          warn "Set pk error: " + e
        end
        pc.send_message("Usage: //setpk <pk_count>")
      end
    elsif (command.starts_with?("admin_setpvp"))
      begin
        val = command.substring(13)
        pvp = val.to_i
        L2Object target = pc.target
        if (target.is_a?(L2PcInstance)
          L2PcInstance player = (L2PcInstance) target
          player.setPvpKills(pvp)
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(new ExBrExtraUserInfo(player))
          player.send_message("A GM changed your PVP count to " + pvp)
          pc.send_message(player.name + "'s PVP count changed to " + pvp)
        end
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      end
      rescue e
        if (Config.developer)
          warn "Set pvp error: " + e
        end
        pc.send_message("Usage: //setpvp <pvp_count>")
      end
    elsif (command.starts_with?("admin_setfame"))
      begin
        val = command.substring(14)
        fame = val.to_i
        L2Object target = pc.target
        if (target.is_a?(L2PcInstance)
          L2PcInstance player = (L2PcInstance) target
          player.setFame(fame)
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(new ExBrExtraUserInfo(player))
          player.send_message("A GM changed your Reputation points to " + fame)
          pc.send_message(player.name + "'s Fame changed to " + fame)
        end
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      end
      rescue e
        if (Config.developer)
          warn "Set Fame error: " + e
        end
        pc.send_message("Usage: //setfame <new_fame_value>")
      end
    elsif (command.starts_with?("admin_rec"))
      begin
        val = command.substring(10)
        recVal = val.to_i
        L2Object target = pc.target
        if (target.is_a?(L2PcInstance)
          L2PcInstance player = (L2PcInstance) target
          player.setRecomHave(recVal)
          player.broadcast_user_info
          player.send_packet(UserInfo.new(player))
          player.send_packet(ExBrExtraUserInfo.new(player))
          player.send_packet(ExVoteSystemInfo.new(player))
          player.send_message("A GM changed your Recommend points to " + recVal)
          pc.send_message(player.name + "'s Recommend changed to " + recVal)
        end
        else
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        end
      end
      rescue e
        pc.send_message("Usage: //rec number")
      end
    elsif (command.starts_with?("admin_setclass"))
      begin
        val = command.substring(15).trim()
        classidval = val.to_i
        L2Object target = pc.target
        L2PcInstance player = null
        if (target.is_a?(L2PcInstance)
          player = (L2PcInstance) target
        end
        else
          return false
        end
        valid = false
        ClassId.each do |classid|
          if (classidval == classid.to_i)
            valid = true
          end
        end
        if (valid && (player.class_id.to_i != classidval))
          TransformData.transform_player(255, player)
          player.class_id = classidval
          if (!player.subclass_active?)
            player.setBaseClass(classidval)
          end
          newclass = ClassListData.get_class!(player.class_id).class_name
          player.store_me
          player.send_message("A GM changed your class to " + newclass + ".")
          player.untransform
          player.broadcast_user_info
          pc.target = null
          pc.target = player
          pc.send_message(player.name + " is a " + newclass + ".")
        end
        else
          pc.send_message("Usage: //setclass <valid_new_classid>")
        end
      end
      rescue e
        AdminHtml.showAdminHtml(pc, "setclass/human_fighter.htm")
      end
      catch (NumberFormatException e)
        pc.send_message("Usage: //setclass <valid_new_classid>")
      end
    elsif (command.starts_with?("admin_settitle"))
      begin
        val = command.substring(15)
        L2Object target = pc.target
        L2PcInstance player = null
        if (target.is_a?(L2PcInstance)
          player = (L2PcInstance) target
        end
        else
          return false
        end
        player.setTitle(val)
        player.send_message("Your title has been changed by a GM")
        player.broadcast_title_info
      end
      rescue e
        pc.send_message("You need to specify the new title.")
      end
    elsif (command.starts_with?("admin_changename"))
      begin
        val = command.substring(17)
        L2Object target = pc.target
        L2PcInstance player = null
        if (target.is_a?(L2PcInstance)
          player = (L2PcInstance) target
        end
        else
          return false
        end
        if (CharNameTable.getInstance().getIdByName(val) > 0)
          pc.send_message("Warning, player " + val + " already exists")
          return false
        end
        player.setName(val)
        player.store_me

        pc.send_message("Changed name to " + val)
        player.send_message("Your name has been changed by a GM.")
        player.broadcast_user_info

        if (player.in_party?)
          # Delete party window for other party members
          player.party.broadcast_to_party_members(player, PartySmallWindowDeleteAll::STATIC_PACKET)
          for (L2PcInstance member : player.party.members)
            # And re-add
            if (member != player)
              member.send_packet(new PartySmallWindowAll(member, player.party))
            end
          end
        end
        if (player.getClan() != null)
          player.getClan().broadcastClanStatus()
        end
      end
      rescue e
        pc.send_message("Usage: //setname new_name_for_target")
      end
    elsif (command.starts_with?("admin_setsex"))
      L2Object target = pc.target
      L2PcInstance player = null
      if (target.is_a?(L2PcInstance)
        player = (L2PcInstance) target
      else
        return false
      end
      player.getAppearance().setSex(player.getAppearance().getSex() ? false : true)
      player.send_message("Your gender has been changed by a GM")
      player.broadcast_user_info
    elsif (command.starts_with?("admin_setcolor"))
      begin
        val = command.substring(15)
        L2Object target = pc.target
        L2PcInstance player = null
        if (target.is_a?(L2PcInstance)
          player = (L2PcInstance) target
        end
        else
          return false
        end
        player.getAppearance().setNameColor(Integer.decode("0x" + val))
        player.send_message("Your name color has been changed by a GM")
        player.broadcast_user_info
      end
      rescue e
        pc.send_message("You need to specify a valid new color.")
      end
    elsif (command.starts_with?("admin_settcolor"))
      begin
        val = command.substring(16)
        L2Object target = pc.target
        L2PcInstance player = null
        if (target.is_a?(L2PcInstance)
          player = (L2PcInstance) target
        end
        else
          return false
        end
        player.getAppearance().setTitleColor(Integer.decode("0x" + val))
        player.send_message("Your title color has been changed by a GM")
        player.broadcast_user_info
      end
      rescue e
        pc.send_message("You need to specify a valid new color.")
      end
    elsif (command.starts_with?("admin_fullfood"))
      L2Object target = pc.target
      if (target instanceof L2PetInstance)
        L2PetInstance targetPet = (L2PetInstance) target
        targetPet.current_feed = targetPet.max_feed
        targetPet.broadcast_status_update
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    elsif (command.starts_with?("admin_remove_clan_penalty"))
      begin
        st = new StringTokenizer(command, ' ')
        if (st.size != 3)
          pc.send_message("Usage: //remove_clan_penalty join|create charname")
          return false
        end

        st.shift

        changeCreateExpiryTime = st.shift.casecmp?("create")

        player_name = st.shift
        L2PcInstance player = null
        player = L2World.get_player(player_name)

        if (player == null)
          updateQuery = "UPDATE characters SET " + (changeCreateExpiryTime ? "clan_create_expiry_time" : "clan_join_expiry_time") + " WHERE char_name=? LIMIT 1"
          begin (Connection con = ConnectionFactory.getInstance().getConnection()
            PreparedStatement ps = con.prepareStatement(updateQuery))
            ps.setString(1, player_name)
            ps.execute()
          end
        end
        else
          # removing penalty
          if (changeCreateExpiryTime)
            player.setClanCreateExpiryTime(0)
          end
          else
            player.setClanJoinExpiryTime(0)
          end
        end

        pc.send_message("Clan penalty successfully removed to character: " + player_name)
      end
      rescue e
        e.printStackTrace()
      end
    elsif (command.starts_with?("admin_find_dualbox"))
      multibox = 2
      begin
        val = command.substring(19)
        multibox = val.to_i
        if (multibox < 1)
          pc.send_message("Usage: //find_dualbox [number > 0]")
          return false
        end
      end
      rescue e
      end
      findDualbox(pc, multibox)
    elsif (command.starts_with?("admin_strict_find_dualbox"))
      multibox = 2
      begin
        val = command.substring(26)
        multibox = val.to_i
        if (multibox < 1)
          pc.send_message("Usage: //strict_find_dualbox [number > 0]")
          return false
        end
      end
      rescue e
      end
      findDualboxStrict(pc, multibox)
    elsif (command.starts_with?("admin_tracert"))
      data = command.split(' ')
      L2PcInstance pl = null
      if ((data.length > 1))
        pl = L2World.get_player(data[1])
      else
        L2Object target = pc.target
        if (target.is_a?(L2PcInstance)
          pl = (L2PcInstance) target
        end
      end

      if (pl == null)
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
        return false
      end

      L2GameClient client = pl.getClient()
      if (client.nil?)
        pc.send_message("Client is null.")
        return false
      end

      if (client.detached?)
        pc.send_message("Client is detached.")
        return false
      end

      trace = client.trace
      for (i = 0; i < trace.length; i++
        ip = ""
        for (o = 0; o < trace[0].length; o++
          ip = ip + trace[i][o]
          if (o != (trace[0].length - 1))
            ip = ip + "."
          end
        end
        pc.send_message("Hop" + i + ": " + ip)
      end
    elsif (command.starts_with?("admin_summon_info"))
      L2Object target = pc.target
      if (target instanceof L2Summon)
        gather_summon_info((L2Summon) target, pc)
      else
        pc.send_message("Invalid target.")
      end
    elsif (command.starts_with?("admin_unsummon"))
      L2Object target = pc.target
      if (target instanceof L2Summon)
        ((L2Summon) target).unSummon(((L2Summon) target).getOwner())
      else
        pc.send_message("Usable only with Pets/Summons")
      end
    elsif (command.starts_with?("admin_summon_setlvl"))
      L2Object target = pc.target
      if (target instanceof L2PetInstance)
        L2PetInstance pet = (L2PetInstance) target
        begin
          val = command.substring(20)
          level = val.to_i
          long newexp, oldexp = 0
          oldexp = pet.stat.exp
          newexp = pet.stat.getExpForLevel(level)
          if (oldexp > newexp)
            pet.stat.removeExp(oldexp - newexp)
          end
          elsif (oldexp < newexp)
            pet.stat.addExp(newexp - oldexp)
          end
        end
        rescue e
        end
      else
        pc.send_message("Usable only with Pets")
      end
    elsif (command.starts_with?("admin_show_pet_inv"))
      L2Object target
      begin
        val = command.substring(19)
        objId = val.to_i
        target = L2World.getPet(objId)
      end
      rescue e
        target = pc.target
      end

      if (target instanceof L2PetInstance)
        pc.send_packet(new GMViewItemList((L2PetInstance) target))
      else
        pc.send_message("Usable only with Pets")
      end

    elsif (command.starts_with?("admin_partyinfo"))
      L2Object target
      begin
        val = command.substring(16)
        target = L2World.get_player(val)
        if target.nil?
          target = pc.target
        end
      end
      rescue e
        target = pc.target
      end

      if (target.is_a?(L2PcInstance)
        if (((L2PcInstance) target).in_party?)
          gather_party_info((L2PcInstance) target, pc)
        end
        else
          pc.send_message("Not in party.")
        end
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end

    elsif (command.equals("admin_setnoble"))
      L2PcInstance player = null
      if (pc.target == null)
        player = pc
      elsif ((pc.target != null) && (pc.target.is_a?(L2PcInstance))
        player = (L2PcInstance) pc.target
      end

      if (player != null)
        player.setNoble(!player.noble?)
        if (player.l2id != pc.l2id)
          pc.send_message("You've changed nobless status of: " + player.name)
        end
        player.send_message("GM changed your nobless status!")
      end
    elsif (command.starts_with?("admin_set_hp"))
      data = command.split(' ')
      begin
        L2Object target = pc.target
        if (target.nil? || !target.isCharacter())
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        ((L2Character) target).setCurrentHp(Double.parseDouble(data[1]))
      end
      rescue e
        pc.send_message("Usage: //set_hp 1000")
      end
    elsif (command.starts_with?("admin_set_mp"))
      data = command.split(' ')
      begin
        L2Object target = pc.target
        if (target.nil? || !target.isCharacter())
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        ((L2Character) target).setCurrentMp(Double.parseDouble(data[1]))
      end
      rescue e
        pc.send_message("Usage: //set_mp 1000")
      end
    elsif (command.starts_with?("admin_set_cp"))
      data = command.split(' ')
      begin
        L2Object target = pc.target
        if (target.nil? || !target.isCharacter())
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        ((L2Character) target).setCurrentCp(Double.parseDouble(data[1]))
      end
      rescue e
        pc.send_message("Usage: //set_cp 1000")
      end
    elsif (command.starts_with?("admin_set_pvp_flag"))
      begin
        L2Object target = pc.target
        if (target.nil? || !target.isPlayable())
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end
        L2Playable playable = ((L2Playable) target)
        playable.update_pvp_flag((playable.pvp_flag - 1).abs)
      end
      rescue e
        pc.send_message("Usage: //set_pvp_flag")
      end
    end
    return true
  end

  private def list_characters(pc, page)
    L2PcInstance[] players = L2World.getPlayersSortedBy(Comparator.comparingLong(L2PcInstance::getUptime))

    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/charlist.htm")

    PageResult result = HtmlUtil.createPage(players, page, 20, i ->
      return "<td align=center><a action=\"bypass -h admin_show_characters " + i + "\">Page " + (i + 1) + "</a></td>"
    end , player ->
      sb = new StringBuilder()
      sb.append("<tr>")
      sb.append("<td width=80><a action=\"bypass -h admin_character_info " + player.name + "\">" + player.name + "</a></td>")
      sb.append("<td width=110>" + ClassListData.get_class!(player.class_id).client_code + "</td><td width=40>" + player.level + "</td>")
      sb.append("</tr>")
      return sb.toString()
    end)

    if (result.getPages() > 0)
      html.replace("%pages%", "<table width=280 cellspacing=0><tr>" + result.getPagerTemplate() + "</tr></table>")
    else
      html.replace("%pages%", "")
    end

    html.replace("%players%", result.getBodyTemplate().toString())
    pc.send_packet(html)
  end

  private show_character_info(L2PcInstance pc, L2PcInstance player)
    if (player == null)
      L2Object target = pc.target
      if (target.is_a?(L2PcInstance)
        player = (L2PcInstance) target
      else
        return
      end
    else
      pc.target = player
    end
    gather_character_info(pc, player, "charinfo.htm")
  end

  private def show_character_info(pc, player)
    if (player == null)
      L2Object target = pc.target
      if (target.is_a?(L2PcInstance)
        player = (L2PcInstance) target
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

    if (player == null)
      pc.send_message("Player is null.")
      return
    end

    L2GameClient client = player.getClient()
    if (client.nil?)
      pc.send_message("Client is null.")
    elsif (client.detached?)
      pc.send_message("Client is detached.")
    else
      ip = client.getConnection().address.getHostAddress()
    end

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/" + filename)
    repl.replace("%name%", player.name)
    repl.replace("%level%", String.valueOf(player.level))
    repl.replace("%clan%", String.valueOf(player.getClan() != null ? "<a action=\"bypass -h admin_clan_info " + player.l2id + "\">" + player.getClan().name + "</a>" : null))
    repl.replace("%xp%", String.valueOf(player.exp))
    repl.replace("%sp%", String.valueOf(player.sp))
    repl.replace("%class%", ClassListData.get_class!(player.class_id).client_code)
    repl.replace("%ordinal%", String.valueOf(player.class_id.ordinal()))
    repl.replace("%classid%", String.valueOf(player.class_id))
    repl.replace("%baseclass%", ClassListData.get_class!(player.base_class).client_code)
    repl.replace("%x%", String.valueOf(player.x))
    repl.replace("%y%", String.valueOf(player.y))
    repl.replace("%z%", String.valueOf(player.z))
    repl.replace("%currenthp%", String.valueOf((int) player.current_hp))
    repl.replace("%maxhp%", String.valueOf(player.max_hp))
    repl.replace("%karma%", String.valueOf(player.karma))
    repl.replace("%currentmp%", String.valueOf((int) player.current_mp))
    repl.replace("%maxmp%", String.valueOf(player.max_mp))
    repl.replace("%pvpflag%", String.valueOf(player.pvp_flag))
    repl.replace("%currentcp%", String.valueOf((int) player.getCurrentCp()))
    repl.replace("%maxcp%", String.valueOf(player.getMaxCp()))
    repl.replace("%pvpkills%", String.valueOf(player.getPvpKills()))
    repl.replace("%pkkills%", String.valueOf(player.getPkKills()))
    repl.replace("%currentload%", String.valueOf(player.getCurrentLoad()))
    repl.replace("%maxload%", String.valueOf(player.getMaxLoad()))
    repl.replace("%percent%", String.valueOf(Util.roundTo(((float) player.getCurrentLoad() / (float) player.getMaxLoad()) * 100, 2)))
    repl.replace("%patk%", String.valueOf((int) player.getPAtk(null)))
    repl.replace("%matk%", String.valueOf((int) player.getMAtk(null, null)))
    repl.replace("%pdef%", String.valueOf((int) player.getPDef(null)))
    repl.replace("%mdef%", String.valueOf((int) player.getMDef(null, null)))
    repl.replace("%accuracy%", String.valueOf(player.getAccuracy()))
    repl.replace("%evasion%", String.valueOf(player.getEvasionRate(null)))
    repl.replace("%critical%", String.valueOf(player.getCriticalHit(null, null)))
    repl.replace("%runspeed%", String.valueOf((int) player.getRunSpeed()))
    repl.replace("%patkspd%", String.valueOf(player.getPAtkSpd()))
    repl.replace("%matkspd%", String.valueOf(player.getMAtkSpd()))
    repl.replace("%access%", player.getAccessLevel().level + " (" + player.getAccessLevel().name + ")")
    repl.replace("%account%", player.getAccountName())
    repl.replace("%ip%", ip)
    repl.replace("%ai%", String.valueOf(player.ai.intention.name()))
    repl.replace("%inst%", player.getInstanceId() > 0 ? "<tr><td>InstanceId:</td><td><a action=\"bypass -h admin_instance_spawns " + String.valueOf(player.getInstanceId()) + "\">" + String.valueOf(player.getInstanceId()) + "</a></td></tr>" : "")
    repl.replace("%noblesse%", player.noble? ? "Yes" : "No")
    pc.send_packet(repl)
  end

  private def set_target_karma(pc, new_karma)
    L2Object target = pc.target
    L2PcInstance player = null
    if (target.is_a?(L2PcInstance)
      player = (L2PcInstance) target
    else
      return
    end

    if (new_karma >= 0)
      # for display
      old_karma = player.karma
      # update karma
      player.setKarma(new_karma)
      # Common character information
      sm = SystemMessageId::YOUR_KARMA_HAS_BEEN_CHANGED_TO_S1
      sm.addInt(new_karma)
      player.send_packet(sm)
      # Admin information
      pc.send_message("Successfully Changed karma for " + player.name + " from (" + old_karma + ") to (" + new_karma + ").")
      if (Config.DEBUG)
        _log.fine("[SET KARMA] [GM]" + pc.name + " Changed karma for " + player.name + " from (" + old_karma + ") to (" + new_karma + ").")
      end
    else
      # tell admin of mistake
      pc.send_message("You must enter a value for karma greater than or equal to 0.")
      if (Config.DEBUG)
        _log.fine("[SET KARMA] ERROR: [GM]" + pc.name + " entered an incorrect value for new karma: " + new_karma + " for " + player.name + ".")
      end
    end
  end

  private def edit_character(pc, targetName)
    if (targetName != null)
      target = L2World.get_player(targetName)
    else
      target = pc.target
    end

    if (target.is_a?(L2PcInstance)
      L2PcInstance player = (L2PcInstance) target
      gather_character_info(pc, player, "charedit.htm")
    end
  end

  private def find_character(pc, CharacterToFind)
    chars_found = 0
    name
    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/charfind.htm")

    rep_msg = new StringBuilder(1000)

    for (L2PcInstance player : L2World.getPlayersSortedBy(Comparator.comparingLong(L2PcInstance::getUptime)))
      name = player.name
      if (name.toLowerCase().contains(CharacterToFind.toLowerCase()))
        chars_found = chars_found + 1
        StringUtil.append(rep_msg, "<tr><td width=80><a action=\"bypass -h admin_character_info ", name, "\">", name, "</a></td><td width=110>", ClassListData.get_class!(player.class_id).client_code, "</td><td width=40>", String.valueOf(player.level), "</td></tr>")
      end
      if (chars_found > 20)
        break
      end
    end
    repl.replace("%results%", rep_msg.toString())

    rep_msg2

    if (chars_found == 0)
      rep_msg2 = "s. Please try again."
    elsif (chars_found > 20)
      repl.replace("%number%", " more than 20")
      rep_msg2 = "s.<br>Please refine your search to see all of the results."
    elsif (chars_found == 1)
      rep_msg2 = "."
    else
      rep_msg2 = "s."
    end

    repl.replace("%number%", chars_found)
    repl.replace("%end%", rep_msg2)
    pc.send_packet(repl)
  end

  private def find_character_per_ip(pc, ipAddress)
    find_disconnected = false

    if (IpAdress.equals("disconnected"))
      find_disconnected = true
    else
        throw new IllegalArgumentException("Malformed IPv4 number")
      end
    end

    chars_found = 0
    ip = "0.0.0.0"
    rep_msg = new StringBuilder(1000)
    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/ipfind.htm")
    for (L2PcInstance player : L2World.getPlayersSortedBy(Comparator.comparingLong(L2PcInstance::getUptime)))
      client = player.getClient()
      if (client.nil?)
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

        ip = client.getConnection().address.getHostAddress()
        if (!ip.equals(IpAdress))
          next
        end
      end

      name = player.name
      chars_found = chars_found + 1
      StringUtil.append(rep_msg, "<tr><td width=80><a action=\"bypass -h admin_character_info ", name, "\">", name, "</a></td><td width=110>", ClassListData.get_class!(player.class_id).client_code, "</td><td width=40>", String.valueOf(player.level), "</td></tr>")

      if (chars_found > 20)
        break
      end
    end
    repl.replace("%results%", rep_msg.toString())

    rep_msg2

    if (chars_found == 0)
      rep_msg2 = "s. Maybe they got d/c? :)"
    elsif (chars_found > 20)
      repl.replace("%number%", " more than " + String.valueOf(chars_found))
      rep_msg2 = "s.<br>In order to avoid you a client crash I won't <br1>display results beyond the 20th character."
    elsif (chars_found == 1)
      rep_msg2 = "."
    else
      rep_msg2 = "s."
    end
    repl.replace("%ip%", IpAdress)
    repl.replace("%number%", String.valueOf(chars_found))
    repl.replace("%end%", rep_msg2)
    pc.send_packet(repl)
  end

  private def find_characters_per_account(pc, characterName)
    player = L2World.get_player(characterName)
    if (player == null)
      throw new IllegalArgumentException("Player doesn't exist")
    end

    Map<Integer, String> chars = player.getAccountChars()
    rep_msg = new StringBuilder(chars.size() * 20)
    chars.values().stream().forEachOrdered(name -> StringUtil.append(rep_msg, name, "<br1>"))

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/accountinfo.htm")
    repl.replace("%account%", player.getAccountName())
    repl.replace("%player%", characterName)
    repl.replace("%characters%", rep_msg.toString())
    pc.send_packet(repl)
  end

  private def find_dualbox(pc, multibox)
    Map<String, List<L2PcInstance>> ipMap = new HashMap<>()
    ip = "0.0.0.0"
    L2GameClient client
    Map<String, Integer> dualboxIPs = new HashMap<>()

    for (L2PcInstance player : L2World.getPlayersSortedBy(Comparator.comparingLong(L2PcInstance::getUptime)))
      client = player.getClient()
      if ((client.nil?) || client.detached?)
        next
      end

      ip = client.getConnection().address.getHostAddress()
      if (ipMap.get(ip) == null)
        ipMap.put(ip, new ArrayList<L2PcInstance>())
      end
      ipMap.get(ip).add(player)

      if (ipMap.get(ip).size() >= multibox)
        Integer count = dualboxIPs.get(ip)
        if (count == null)
          dualboxIPs.put(ip, multibox)
        end
        else
          dualboxIPs.put(ip, count + 1)
        end
      end
    end

    List<String> keys = new ArrayList<>(dualboxIPs.keySet())
    keys.sort(Comparator.comparing(s -> dualboxIPs.get(s)).reversed())

    results = new StringBuilder()
    for (String dualboxIP : keys)
      StringUtil.append(results, "<a action=\"bypass -h admin_find_ip " + dualboxIP + "\">" + dualboxIP + " (" + dualboxIPs.get(dualboxIP) + ")</a><br1>")
    end

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/dualbox.htm")
    repl.replace("%multibox%", String.valueOf(multibox))
    repl.replace("%results%", results.toString())
    repl.replace("%strict%", "")
    pc.send_packet(repl)
  end

  private def find_dualbox_strict(pc, multibox)
    Map<IpPack, List<L2PcInstance>> ipMap = new HashMap<>()
    L2GameClient client
    Map<IpPack, Integer> dualboxIPs = new HashMap<>()

    for (L2PcInstance player : L2World.getPlayersSortedBy(Comparator.comparingLong(L2PcInstance::getUptime)))
      client = player.getClient()
      if ((client.nil?) || client.detached?)
        next
      end

      IpPack pack = new IpPack(client.getConnection().address.getHostAddress(), client.trace)
      if (ipMap.get(pack) == null)
        ipMap.put(pack, new ArrayList<L2PcInstance>())
      end
      ipMap.get(pack).add(player)

      if (ipMap.get(pack).size() >= multibox)
        Integer count = dualboxIPs.get(pack)
        if (count == null)
          dualboxIPs.put(pack, multibox)
        end
        else
          dualboxIPs.put(pack, count + 1)
        end
      end
    end

    List<IpPack> keys = new ArrayList<>(dualboxIPs.keySet())
    keys.sort(Comparator.comparing(s -> dualboxIPs.get(s)).reversed())

    results = new StringBuilder()
    for (IpPack dualboxIP : keys)
      StringUtil.append(results, "<a action=\"bypass -h admin_find_ip " + dualboxIP.ip + "\">" + dualboxIP.ip + " (" + dualboxIPs.get(dualboxIP) + ")</a><br1>")
    end

    repl = NpcHtmlMessage.new
    repl.set_file(pc, "data/html/admin/dualbox.htm")
    repl.replace("%multibox%", String.valueOf(multibox))
    repl.replace("%results%", results.toString())
    repl.replace("%strict%", "strict_")
    pc.send_packet(repl)
  end

  private def gather_summon_info(target, pc)
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/petinfo.htm")
    name = target.name
    html.replace("%name%", name == null ? "N/A" : name)
    html.replace("%level%", Integer.toString(target.level))
    html.replace("%exp%", Long.toString(target.stat.exp))
    owner = target.acting_player.name
    html.replace("%owner%", " <a action=\"bypass -h admin_character_info " + owner + "\">" + owner + "</a>")
    html.replace("%class%", target.getClass().getSimpleName())
    html.replace("%ai%", target.hasAI() ? String.valueOf(target.ai.intention.name()) : "NULL")
    html.replace("%hp%", (int) target.getStatus().current_hp + "/" + target.stat.max_hp)
    html.replace("%mp%", (int) target.getStatus().current_mp + "/" + target.stat.max_mp)
    html.replace("%karma%", Integer.toString(target.karma))
    html.replace("%race%", target.getTemplate().race.toString())
    if (target instanceof L2PetInstance)
      objId = target.acting_player.l2id
      html.replace("%inv%", " <a action=\"bypass admin_show_pet_inv " + objId + "\">view</a>")
    else
      html.replace("%inv%", "none")
    end
    if (target instanceof L2PetInstance)
      html.replace("%food%", ((L2PetInstance) target).getCurrentFed() + "/" + ((L2PetInstance) target).getPetLevelData().getPetMaxFeed())
      html.replace("%load%", ((L2PetInstance) target).getInventory().getTotalWeight() + "/" + ((L2PetInstance) target).getMaxLoad())
    else
      html.replace("%food%", "N/A")
      html.replace("%load%", "N/A")
    end
    pc.send_packet(html)
  end

  private def gather_party_info(target, pc)
    color = true
    html = NpcHtmlMessage.new
    html.set_file(pc, "data/html/admin/partyinfo.htm")
    text = new StringBuilder(400)
    for (L2PcInstance member : target.party.members)
      if (color)
        text.append("<tr><td><table width=270 border=0 bgcolor=131210 cellpadding=2><tr><td width=30 align=right>")
      else
        text.append("<tr><td><table width=270 border=0 cellpadding=2><tr><td width=30 align=right>")
      end
      text.append(member.level + "</td><td width=130><a action=\"bypass -h admin_character_info " + member.name + "\">" + member.name + "</a>")
      text.append("</td><td width=110 align=right>" + member.class_id.toString() + "</td></tr></table></td></tr>")
      color = !color
    end
    html.replace("%player%", target.name)
    html.replace("%party%", text.toString())
    pc.send_packet(html)
  end

  def commands
    %w()
  end
end
