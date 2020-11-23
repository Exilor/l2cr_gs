class L2FortManagerInstance < L2MerchantInstance
  private COND_ALL_FALSE = 0
  private COND_BUSY_BECAUSE_OF_SIEGE = 1
  private COND_OWNER = 2

  private alias WarehouseListType = SortedWareHouseWithdrawalList::WarehouseListType

  def instance_type : InstanceType
    InstanceType::L2FortManagerInstance
  end

  def warehouse? : Bool
    true
  end

  private struct SimpleDateFormat
    initializer format : String

    def format(n)
      sprintf(@format, n)
    end
  end

  private def send_html_message(pc, html)
    html["%objectId%"] = l2id
    html["%npcId%"] = id
    pc.send_packet(html)
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    if pc.last_folk_npc.not_nil!.l2id != l2id
      return
    end
    format = SimpleDateFormat.new("%d/%m/%Y %H:%m")
    condition = validate_condition(pc)
    if condition <= COND_ALL_FALSE
      return
    elsif condition == COND_BUSY_BECAUSE_OF_SIEGE
      return
    elsif condition == COND_OWNER
      st = command.split
      actual_command = st.shift # Get actual command

      val = ""
      if st.size >= 1
        val = st.shift
      end

      if actual_command.casecmp?("expel")
        if pc.has_clan_privilege?(ClanPrivilege::CS_DISMISS)
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-expel.htm")
          html["%objectId%"] = l2id
          pc.send_packet(html)
        else
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-noprivs.htm")
          html["%objectId%"] = l2id
          pc.send_packet(html)
        end
        return
      elsif actual_command.casecmp?("banish_foreigner")
        if pc.has_clan_privilege?(ClanPrivilege::CS_DISMISS)
          fort.banish_foreigners # Move non-clan members off fortress area
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-expeled.htm")
          html["%objectId%"] = l2id
          pc.send_packet(html)
        else
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-noprivs.htm")
          html["%objectId%"] = l2id
          pc.send_packet(html)
        end
        return
      elsif actual_command.casecmp?("receive_report")
        if fort.fort_state < 2
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-report.htm")
          html["%objectId%"] = l2id
          if Config.fs_max_own_time > 0
            hour = (fort.time_until_rebel_army // 3600).to_i
            minutes = ((fort.time_until_rebel_army - (hour * 3600)) // 60).to_i
            html["%hr%"] = hour
            html["%min%"] = minutes
          else
            hour = (fort.owned_time // 3600).to_i
            minutes = ((fort.owned_time - (hour * 3600)) // 60).to_i
            html["%hr%"] = hour
            html["%min%"] = minutes
          end
          pc.send_packet(html)
        else
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-castlereport.htm")
          html["%objectId%"] = l2id
          if Config.fs_max_own_time > 0
            hour = (fort.time_until_rebel_army // 3600).to_i
            minutes = ((fort.time_until_rebel_army - (hour * 3600)) // 60).to_i
            html["%hr%"] = hour
            html["%min%"] = minutes
          else
            hour = (fort.owned_time // 3600).to_i
            minutes = ((fort.owned_time - (hour * 3600)) // 60).to_i
            html["%hr%"] = hour
            html["%min%"] = minutes
          end
          hour = (fort.time_until_next_fort_update // 3600).to_i
          minutes = ((fort.time_until_next_fort_update - (hour * 3600)) // 60).to_i
          html["%castle%"] = fort.contracted_castle.name
          html["%hr2%"] = hour
          html["%min2%"] = minutes
          pc.send_packet(html)
        end
        return
      elsif actual_command.casecmp?("operate_door")
        if pc.has_clan_privilege?(ClanPrivilege::CS_OPEN_DOOR)
          if !val.empty?
            open = val.to_i == 1
            st.each do |token|
              fort.open_close_door(pc, token.to_i, open)
            end
            if open
              html = NpcHtmlMessage.new(l2id)
              html.set_file(pc, "data/html/fortress/foreman-opened.htm")
              html["%objectId%"] = l2id
              pc.send_packet(html)
            else
              html = NpcHtmlMessage.new(l2id)
              html.set_file(pc, "data/html/fortress/foreman-closed.htm")
              html["%objectId%"] = l2id
              pc.send_packet(html)
            end
          else
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/fortress/#{template.id}-d.htm")
            html["%objectId%"] = l2id
            html["%npcname%"] = name
            pc.send_packet(html)
          end
        else
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-noprivs.htm")
          html["%objectId%"] = l2id
          pc.send_packet(html)
        end
        return
      elsif actual_command.casecmp?("manage_vault")
        html = NpcHtmlMessage.new(l2id)
        if pc.has_clan_privilege?(ClanPrivilege::CL_VIEW_WAREHOUSE)
          if val.casecmp?("deposit")
            show_vault_window_deposit(pc)
          elsif val.casecmp?("withdraw")
            if Config.enable_warehousesorting_clan
              htm_file = "data/html/mods/WhSortedC.htm"

              if htm_content = HtmCache.get_htm(pc, htm_file)
                npc_html_message = NpcHtmlMessage.new(l2id)
                npc_html_message.html = htm_content
                npc_html_message["%objectId%"] = l2id
                pc.send_packet(npc_html_message)
              else
                warn { "Missing html #{htm_file}." }
              end
            else
              show_vault_window_withdraw(pc, nil, 0i8)
            end
          else
            html.set_file(pc, "data/html/fortress/foreman-vault.htm")
            send_html_message(pc, html)
          end
        else
          html.set_file(pc, "data/html/fortress/foreman-noprivs.htm")
          send_html_message(pc, html)
        end
        return
      elsif actual_command.starts_with?("WithdrawSortedC")
        param = command.split('_')
        if param.size > 2
          show_vault_window_withdraw(pc, WarehouseListType.parse(param[1]), SortedWareHouseWithdrawalList.get_order(param[2]))
        elsif param.size > 1
          show_vault_window_withdraw(pc, WarehouseListType.parse(param[1]), SortedWareHouseWithdrawalList::A2Z)
        else
          show_vault_window_withdraw(pc, WarehouseListType::ALL, SortedWareHouseWithdrawalList::A2Z)
        end
        return
      elsif actual_command.casecmp?("functions")
        if val.casecmp?("tele")
          html = NpcHtmlMessage.new(l2id)
          if fort.get_function(Fort::FUNC_TELEPORT).nil?
            html.set_file(pc, "data/html/fortress/foreman-nac.htm")
          else
            html.set_file(pc, "data/html/fortress/#{id}-t#{fort.get_function(Fort::FUNC_TELEPORT).not_nil!.lvl}.htm")
          end
          send_html_message(pc, html)
        elsif val.casecmp?("support")
          html = NpcHtmlMessage.new(l2id)
          if fort.get_function(Fort::FUNC_SUPPORT).nil?
            html.set_file(pc, "data/html/fortress/foreman-nac.htm")
          else
            html.set_file(pc, "data/html/fortress/support#{fort.get_function(Fort::FUNC_SUPPORT).not_nil!.lvl}.htm")
            html["%mp%"] = current_mp.to_i
          end
          send_html_message(pc, html)
        elsif val.casecmp?("back")
          show_chat_window(pc)
        else
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-functions.htm")
          if func = fort.get_function(Fort::FUNC_RESTORE_EXP)
            html["%xp_regen%"] = func.lvl
          else
            html["%xp_regen%"] = "0"
          end
          if func = fort.get_function(Fort::FUNC_RESTORE_HP)
            html["%hp_regen%"] = func.lvl
          else
            html["%hp_regen%"] = "0"
          end
          if func = fort.get_function(Fort::FUNC_RESTORE_MP)
            html["%mp_regen%"] = func.lvl
          else
            html["%mp_regen%"] = "0"
          end
          send_html_message(pc, html)
        end
        return
      elsif actual_command.casecmp?("manage")
        if pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
          if val.casecmp?("recovery")
            if st.size >= 1
              unless fort.owner_clan?
                pc.send_message("This fortress has no owner, you cannot change the configuration.")
                return
              end
              val = st.shift
              if val.casecmp?("hp_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-cancel.htm")
                html["%apply%"] = "recovery hp 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("mp_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-cancel.htm")
                html["%apply%"] = "recovery mp 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("exp_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-cancel.htm")
                html["%apply%"] = "recovery exp 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_hp")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-apply.htm")
                html["%name%"] = "(HP Recovery Device)"
                percent = val.to_i
                case percent
                when 300
                  cost = Config.fs_hpreg1_fee
                else # 400
                  cost = Config.fs_hpreg2_fee
                end

                html["%cost%"] = "#{cost}</font>Adena /#{Config.fs_hpreg_fee_ratio // 1000 // 60 // 60 // 24} Day</font>)"
                html["%use%"] = "Provides additional HP recovery for clan members in the fortress.<font color=\"00FFFF\">#{percent}%</font>"
                html["%apply%"] = "recovery hp #{percent}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_mp")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-apply.htm")
                html["%name%"] = "(MP Recovery)"
                percent = val.to_i
                case percent
                when 40
                  cost = Config.fs_mpreg1_fee
                else # 50
                  cost = Config.fs_mpreg2_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.fs_mpreg_fee_ratio // 1000 // 60 // 60 // 24} Day</font>)"
                html["%use%"] = "Provides additional MP recovery for clan members in the fortress.<font color=\"00FFFF\">#{percent}%</font>"
                html["%apply%"] = "recovery mp #{percent}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_exp")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-apply.htm")
                html["%name%"] = "(EXP Recovery Device)"
                percent = val.to_i
                case percent
                when 45
                  cost = Config.fs_expreg1_fee
                else # 50
                  cost = Config.fs_expreg2_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.fs_expreg_fee_ratio // 1000 // 60 // 60 // 24} Day</font>)"
                html["%use%"] = "Restores the Exp of any clan member who is resurrected in the fortress.<font color=\"00FFFF\">#{percent}%</font>"
                html["%apply%"] = "recovery exp #{percent}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("hp")
                if st.size >= 1
                  debug "Mp editing invoked"
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/fortress/functions-apply_confirmed.htm")
                  if func = fort.get_function(Fort::FUNC_RESTORE_HP)
                    if func.lvl == val.to_i
                      html.set_file(pc, "data/html/fortress/functions-used.htm")
                      html["%val%"] = "#{val}%"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  percent = val.to_i
                  case percent
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/fortress/functions-cancel_confirmed.htm")
                  when 300
                    fee = Config.fs_hpreg1_fee
                  else # 400
                    fee = Config.fs_hpreg2_fee
                  end
                  unless fort.update_functions(pc, Fort::FUNC_RESTORE_HP, percent, fee, Config.fs_hpreg_fee_ratio, fort.get_function(Fort::FUNC_RESTORE_HP).nil?)
                    html.set_file(pc, "data/html/fortress/low_adena.htm")
                    send_html_message(pc, html)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("mp")
                if st.size >= 1
                  debug "Mp editing invoked"
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/fortress/functions-apply_confirmed.htm")
                  if func = fort.get_function(Fort::FUNC_RESTORE_MP)
                    if func.lvl == val.to_i
                      html.set_file(pc, "data/html/fortress/functions-used.htm")
                      html["%val%"] = "#{val}%"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  percent = val.to_i
                  case percent
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/fortress/functions-cancel_confirmed.htm")
                  when 40
                    fee = Config.fs_mpreg1_fee
                  else # 50
                    fee = Config.fs_mpreg2_fee
                  end
                  unless fort.update_functions(pc, Fort::FUNC_RESTORE_MP, percent, fee, Config.fs_mpreg_fee_ratio, fort.get_function(Fort::FUNC_RESTORE_MP).nil?)
                    html.set_file(pc, "data/html/fortress/low_adena.htm")
                    send_html_message(pc, html)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("exp")
                if st.size >= 1
                  debug "Exp editing invoked"
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/fortress/functions-apply_confirmed.htm")
                  if func = fort.get_function(Fort::FUNC_RESTORE_EXP)
                    if func.lvl == val.to_i
                      html.set_file(pc, "data/html/fortress/functions-used.htm")
                      html["%val%"] = "#{val}%"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  percent = val.to_i
                  case percent
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/fortress/functions-cancel_confirmed.htm")
                  when 45
                    fee = Config.fs_expreg1_fee
                  else # 50
                    fee = Config.fs_expreg2_fee
                  end
                  unless fort.update_functions(pc, Fort::FUNC_RESTORE_EXP, percent, fee, Config.fs_expreg_fee_ratio, fort.get_function(Fort::FUNC_RESTORE_EXP).nil?)
                    html.set_file(pc, "data/html/fortress/low_adena.htm")
                    send_html_message(pc, html)
                  end
                  send_html_message(pc, html)
                end
                return
              end
            end
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/fortress/edit_recovery.htm")
            hp = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 300\">300%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 400\">400%</a>]"
            exp = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 45\">45%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 50\">50%</a>]"
            mp = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 40\">40%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 50\">50%</a>]"
            if func = fort.get_function(Fort::FUNC_RESTORE_HP)
              html["%hp_recovery%"] = "#{func.lvl}%</font> (<font color=\"FFAABB\">#{func.lease}</font>Adena /#{Config.fs_hpreg_fee_ratio // 1000 // 60 // 60 // 24} Day)"
              html["%hp_period%"] = "Withdraw the fee for the next time at #{format.format(func.end_time)}"
              html["%change_hp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery hp_cancel\">Deactivate</a>]#{hp}"
            else
              html["%hp_recovery%"] = "none"
              html["%hp_period%"] = "none"
              html["%change_hp%"] = hp
            end
            if func = fort.get_function(Fort::FUNC_RESTORE_EXP)
              html["%exp_recovery%"] = "#{func.lvl}%</font> (<font color=\"FFAABB\">#{func.lease}</font>Adena /#{Config.fs_expreg_fee_ratio // 1000 // 60 // 60 // 24} Day)"
              html["%exp_period%"] = "Withdraw the fee for the next time at #{format.format(func.end_time)}"
              html["%change_exp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery exp_cancel\">Deactivate</a>]#{exp}"
            else
              html["%exp_recovery%"] = "none"
              html["%exp_period%"] = "none"
              html["%change_exp%"] = exp
            end
            if func = fort.get_function(Fort::FUNC_RESTORE_MP)
              html["%mp_recovery%"] = "#{func.lvl}%</font> (<font color=\"FFAABB\">#{func.lease}</font>Adena /#{Config.fs_mpreg_fee_ratio // 1000 // 60 // 60 // 24} Day)"
              html["%mp_period%"] = "Withdraw the fee for the next time at #{format.format(func.end_time)}"
              html["%change_mp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery mp_cancel\">Deactivate</a>]#{mp}"
            else
              html["%mp_recovery%"] = "none"
              html["%mp_period%"] = "none"
              html["%change_mp%"] = mp
            end
            send_html_message(pc, html)
          elsif val.casecmp?("other")
            if st.size >= 1
              unless fort.owner_clan?
                pc.send_message("This fortress has no owner, you cannot change the configuration.")
                return
              end
              val = st.shift
              if val.casecmp?("tele_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-cancel.htm")
                html["%apply%"] = "other tele 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("support_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-cancel.htm")
                html["%apply%"] = "other support 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_support")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-apply.htm")
                html["%name%"] = "Insignia (Supplementary Magic)"
                stage = val.to_i
                case stage
                when 1
                  cost = Config.fs_support1_fee
                else
                  cost = Config.fs_support2_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.fs_support_fee_ratio // 1000 // 60 // 60 // 24} Day</font>)"
                html["%use%"] = "Enables the use of supplementary magic."
                html["%apply%"] = "other support #{stage}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_tele")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/fortress/functions-apply.htm")
                html["%name%"] = "Mirror (Teleportation Device)"
                stage = val.to_i
                case stage
                when 1
                  cost = Config.fs_tele1_fee
                else
                  cost = Config.fs_tele2_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.fs_tele_fee_ratio // 1000 // 60 // 60 // 24} Day</font>)"
                html["%use%"] = "Teleports clan members in a fort to the target <font color=\"00FFFF\">Stage #{stage}</font> staging area"
                html["%apply%"] = "other tele #{stage}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("tele")
                if st.size >= 1
                  debug "Tele editing invoked"
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/fortress/functions-apply_confirmed.htm")
                  if fort.get_function(Fort::FUNC_TELEPORT)
                    if fort.get_function(Fort::FUNC_TELEPORT).not_nil!.lvl == val.to_i
                      html.set_file(pc, "data/html/fortress/functions-used.htm")
                      html["%val%"] = "Stage #{val}"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  lvl = val.to_i
                  case lvl
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/fortress/functions-cancel_confirmed.htm")
                  when 1
                    fee = Config.fs_tele1_fee
                  else
                    fee = Config.fs_tele2_fee
                  end
                  unless fort.update_functions(pc, Fort::FUNC_TELEPORT, lvl, fee, Config.fs_tele_fee_ratio, fort.get_function(Fort::FUNC_TELEPORT).nil?)
                    html.set_file(pc, "data/html/fortress/low_adena.htm")
                    send_html_message(pc, html)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("support")
                if st.size >= 1
                  debug "Support editing invoked"
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/fortress/functions-apply_confirmed.htm")
                  if fort.get_function(Fort::FUNC_SUPPORT)
                    if fort.get_function(Fort::FUNC_SUPPORT).not_nil!.lvl == val.to_i
                      html.set_file(pc, "data/html/fortress/functions-used.htm")
                      html["%val%"] = "Stage #{val}"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  lvl = val.to_i
                  case lvl
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/fortress/functions-cancel_confirmed.htm")
                  when 1
                    fee = Config.fs_support1_fee
                  else
                    fee = Config.fs_support2_fee
                  end
                  if !fort.update_functions(pc, Fort::FUNC_SUPPORT, lvl, fee, Config.fs_support_fee_ratio, fort.get_function(Fort::FUNC_SUPPORT).nil?)
                    html.set_file(pc, "data/html/fortress/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    send_html_message(pc, html)
                  end
                end
                return
              end
            end
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/fortress/edit_other.htm")
            tele = "[<a action=\"bypass -h npc_%objectId%_manage other edit_tele 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_tele 2\">Level 2</a>]"
            support = "[<a action=\"bypass -h npc_%objectId%_manage other edit_support 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 2\">Level 2</a>]"
            if func = fort.get_function(Fort::FUNC_TELEPORT)
              html["%tele%"] = "Stage #{func.lvl}</font> (<font color=\"FFAABB\">#{func.lease}</font>Adena /#{Config.fs_tele_fee_ratio // 1000 // 60 // 60 // 24} Day)"
              html["%tele_period%"] = "Withdraw the fee for the next time at #{format.format(func.end_time)}"
              html["%change_tele%"] = "[<a action=\"bypass -h npc_%objectId%_manage other tele_cancel\">Deactivate</a>]#{tele}"
            else
              html["%tele%"] = "none"
              html["%tele_period%"] = "none"
              html["%change_tele%"] = tele
            end
            if func = fort.get_function(Fort::FUNC_SUPPORT)
              html["%support%"] = "Stage #{func.lvl}</font> (<font color=\"FFAABB\">#{func.lease}</font>Adena /#{Config.fs_support_fee_ratio // 1000 // 60 // 60 // 24} Day)"
              html["%support_period%"] = "Withdraw the fee for the next time at #{format.format(func.end_time)}"
              html["%change_support%"] = "[<a action=\"bypass -h npc_%objectId%_manage other support_cancel\">Deactivate</a>]#{support}"
            else
              html["%support%"] = "none"
              html["%support_period%"] = "none"
              html["%change_support%"] = support
            end
            send_html_message(pc, html)
          elsif val.casecmp?("back")
            show_chat_window(pc)
          else
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/fortress/manage.htm")
            send_html_message(pc, html)
          end
        else
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/fortress/foreman-noprivs.htm")
          send_html_message(pc, html)
        end
        return
      elsif actual_command.casecmp?("support")
        self.target = pc
        if val.empty?
          return
        end

        begin
          skill_id = val.to_i
          begin
            if fort.get_function(Fort::FUNC_SUPPORT).nil?
              return
            end
            if fort.get_function(Fort::FUNC_SUPPORT).not_nil!.lvl == 0
              return
            end
            html = NpcHtmlMessage.new(l2id)
            skill_lvl = 0
            if st.size >= 1
              skill_lvl = st.shift.to_i
            end
            skill = SkillData[skill_id, skill_lvl]
            if skill.has_effect_type?(EffectType::SUMMON)
              pc.do_cast(skill)
            else
              if !(skill.mp_consume1 + skill.mp_consume2 > current_mp)
                do_cast(skill)
              else
                html.set_file(pc, "data/html/fortress/support-no_mana.htm")
                html["%mp%"] = current_mp.to_i
                send_html_message(pc, html)
                return
              end
            end
            html.set_file(pc, "data/html/fortress/support-done.htm")
            html["%mp%"] = current_mp.to_i
            send_html_message(pc, html)
          rescue e
            warn e
            pc.send_message("Invalid skill level, contact your admin")
          end
        rescue e
          warn e
          pc.send_message("Invalid skill level, contact your admin")
        end
        return
      elsif actual_command.casecmp?("support_back")
        html = NpcHtmlMessage.new(l2id)
        if fort.get_function(Fort::FUNC_SUPPORT).not_nil!.lvl == 0
          return
        end
        html.set_file(pc, "data/html/fortress/support#{fort.get_function(Fort::FUNC_SUPPORT).not_nil!.lvl}.htm")
        html["%mp%"] = status.current_mp.to_i
        send_html_message(pc, html)
        return
      elsif actual_command.casecmp?("goto")
        where_to = val.to_i
        do_teleport(pc, where_to)
        return
      end

      super
    end
  end

  def show_chat_window(pc : L2PcInstance)
    pc.action_failed
    filename = "data/html/fortress/foreman-no.htm"

    condition = validate_condition(pc)
    if condition > COND_ALL_FALSE
      if condition == COND_BUSY_BECAUSE_OF_SIEGE
        filename = "data/html/fortress/foreman-busy.htm" # Busy because of siege
      elsif condition == COND_OWNER
        filename = "data/html/fortress/foreman.htm" # Owner message window
      end
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, filename)
    html["%objectId%"] = l2id
    html["%npcname%"] = name
    pc.send_packet(html)
  end

  private def do_teleport(pc, val)
    debug "do_teleport(pc, val) called"
    if list = TeleportLocationTable[val]?
      if pc.destroy_item_by_item_id("Teleport", list.item_id, list.price, self, true)
        debug { "Teleporting player #{pc.name} for Fortress to new location: #{list.x} #{list.y} #{list.z}" }
        pc.tele_to_location(list.x, list.y, list.z)
      end
    else
      debug { "No teleport destination with id: #{val}" }
    end
    pc.action_failed
  end

  private def validate_condition(pc : L2PcInstance) : Int32
    fort = fort?
    if fort && fort.residence_id > 0
      if clan = pc.clan
        if fort.zone.active?
          return COND_BUSY_BECAUSE_OF_SIEGE # Busy because of siege
        elsif fort.owner_clan? && fort.owner_clan.id == pc.clan_id
          return COND_OWNER # Owner
        end
      end
    end

    COND_ALL_FALSE
  end

  private def show_vault_window_deposit(pc)
    pc.action_failed
    pc.active_warehouse = pc.clan.not_nil!.warehouse
    pc.send_packet(WareHouseDepositList.new(pc, WareHouseDepositList::CLAN))
  end

  private def show_vault_window_withdraw(pc, item_type, sort_order)
    if pc.clan_leader? || pc.has_clan_privilege?(ClanPrivilege::CL_VIEW_WAREHOUSE)
      pc.action_failed
      pc.active_warehouse = pc.clan.not_nil!.warehouse
      if item_type
        pc.send_packet(SortedWareHouseWithdrawalList.new(pc, WareHouseWithdrawalList::CLAN, item_type, sort_order))
      else
        pc.send_packet(WareHouseWithdrawalList.new(pc, WareHouseWithdrawalList::CLAN))
      end
    else
      html = NpcHtmlMessage.new(l2id)
      html.set_file(pc, "data/html/fortress/foreman-noprivs.htm")
      send_html_message(pc, html)
    end
  end
end
