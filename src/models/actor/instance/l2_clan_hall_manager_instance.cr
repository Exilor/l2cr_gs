require "./l2_merchant_instance"

class L2ClanHallManagerInstance < L2MerchantInstance
  private COND_OWNER_FALSE = 0
  private COND_ALL_FALSE = 1
  private COND_BUSY_BECAUSE_OF_SIEGE = 2
  private COND_OWNER = 3

  @clan_hall_id =-1

  def instance_type : InstanceType
    InstanceType::L2ClanHallManagerInstance
  end

  def warehouse? : Bool
    true
  end

  def on_bypass_feedback(pc : L2PcInstance, command : String)
    if clan_hall.siegable_hall? && clan_hall.as(SiegableHall).in_siege?
      return
    end

    condition = validate_condition(pc)
    if condition <= COND_ALL_FALSE
      return
    end

    format = "%d/%m/%Y %H:%M"

    if condition == COND_OWNER
      st = command.split
      actual_command = st.shift
      val = ""
      if st.size >= 1
        val = st.shift
      end

      if actual_command.casecmp?("banish_foreigner")
        html = NpcHtmlMessage.new(l2id)
        if pc.has_clan_privilege?(ClanPrivilege::CH_DISMISS)
          if val.casecmp?("list")
            html.set_file(pc, "data/html/clanHallManager/banish-list.htm")
          elsif val.casecmp?("banish")
            clan_hall.banish_foreigners
            html.set_file(pc, "data/html/clanHallManager/banish.htm")
          end
        else
          html.set_file(pc, "data/html/clanHallManager/not_authorized.htm")
        end

        send_html_message(pc, html)
        return
      elsif actual_command.casecmp?("manage_vault")
        html = NpcHtmlMessage.new(l2id)
        if pc.has_clan_privilege?(ClanPrivilege::CL_VIEW_WAREHOUSE)
          if clan_hall.lease <= 0
            html.set_file(pc, "data/html/clanHallManager/vault-chs.htm")
          else
            html.set_file(pc, "data/html/clanHallManager/vault.htm")
            html["%rent%"] = clan_hall.lease
            html["%date%"] = Time.from_ms(clan_hall.paid_until).to_s(format)
          end

          send_html_message(pc, html)
        else
          html.set_file(pc, "data/html/clanHallManager/not_authorized.htm")
          send_html_message(pc, html)
        end

        return
      elsif actual_command.casecmp?("door")
        html = NpcHtmlMessage.new(l2id)
        if pc.has_clan_privilege?(ClanPrivilege::CH_OPEN_DOOR)
          if val.casecmp?("open")
            clan_hall.open_close_doors(true)
            html.set_file(pc, "data/html/clanHallManager/door-open.htm")
          elsif val.casecmp?("close")
            clan_hall.open_close_doors(false)
            html.set_file(pc, "data/html/clanHallManager/door-close.htm")
          else
            html.set_file(pc, "data/html/clanHallManager/door.htm")
          end

          send_html_message(pc, html)
        else
          html.set_file(pc, "data/html/clanHallManager/not_authorized.htm")
          send_html_message(pc, html)
        end

        return
      elsif actual_command.casecmp?("functions")
        if val.casecmp?("tele")
          html = NpcHtmlMessage.new(l2id)
          fn = clan_hall.get_function(ClanHall::FUNC_TELEPORT)
          if fn.nil?
            html.set_file(pc, "data/html/clanHallManager/chamberlain-nac.htm")
          else
            html.set_file(pc, "data/html/clanHallManager/tele#{clan_hall.location}#{fn.lvl}.htm")
          end
          send_html_message(pc, html)
        elsif val.casecmp?("item_creation")
          unless fn = clan_hall.get_function(ClanHall::FUNC_ITEM_CREATE)
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/clanHallManager/chamberlain-nac.htm")
            send_html_message(pc, html)
            return
          end
          if st.empty?
            return
          end
          val_buy = st.shift.to_i + (fn.lvl * 100000)
          show_buy_window(pc, val_buy)
        elsif val.casecmp?("support")

          html = NpcHtmlMessage.new(l2id)
          fn = clan_hall.get_function(ClanHall::FUNC_SUPPORT)
          if fn.nil?
            html.set_file(pc, "data/html/clanHallManager/chamberlain-nac.htm")
          else
            html.set_file(pc, "data/html/clanHallManager/support#{fn.lvl}.htm")
            html["%mp%"] = current_mp.to_i
          end
          send_html_message(pc, html)
        elsif val.casecmp?("back")
          show_chat_window(pc)
        else
          html = NpcHtmlMessage.new(l2id)
          html.set_file(pc, "data/html/clanHallManager/functions.htm")
          if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_EXP)
            html["%xp_regen%"] = fn.lvl
          else
            html["%xp_regen%"] = "0"
          end
          if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_HP)
            html["%hp_regen%"] = fn.lvl
          else
            html["%hp_regen%"] = "0"
          end
          if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_MP)
            html["%mp_regen%"] = fn.lvl
          else
            html["%mp_regen%"] = "0"
          end
          send_html_message(pc, html)
        end
        return
      elsif actual_command.casecmp?("manage")
        if pc.has_clan_privilege?(ClanPrivilege::CH_SET_FUNCTIONS)
          if val.casecmp?("recovery")
            if st.size >= 1
              if clan_hall.owner_id == 0
                pc.send_message("This clan hall has no owner, you cannot change the configuration.")
                return
              end
              val = st.shift
              if val.casecmp?("hp_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "recovery hp 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("mp_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "recovery mp 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("exp_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "recovery exp 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_hp")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Fireplace (HP Recovery Device)"
                percent = val.to_i
                case percent
                when 20
                  cost = Config.ch_hpreg1_fee
                when 40
                  cost = Config.ch_hpreg2_fee
                when 80
                  cost = Config.ch_hpreg3_fee
                when 100
                  cost = Config.ch_hpreg4_fee
                when 120
                  cost = Config.ch_hpreg5_fee
                when 140
                  cost = Config.ch_hpreg6_fee
                when 160
                  cost = Config.ch_hpreg7_fee
                when 180
                  cost = Config.ch_hpreg8_fee
                when 200
                  cost = Config.ch_hpreg9_fee
                when 220
                  cost = Config.ch_hpreg10_fee
                when 240
                  cost = Config.ch_hpreg11_fee
                when 260
                  cost = Config.ch_hpreg12_fee
                else
                  cost = Config.ch_hpreg13_fee
                end

                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_hpreg_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "Provides additional HP recovery for clan members in the clan hall.<font color=\"00FFFF\">#{percent}%</font>"
                html["%apply%"] = "recovery hp #{percent}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_mp")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Carpet (MP Recovery)"
                percent = val.to_i
                case percent
                when 5
                  cost = Config.ch_mpreg1_fee
                when 10
                  cost = Config.ch_mpreg2_fee
                when 15
                  cost = Config.ch_mpreg3_fee
                when 30
                  cost = Config.ch_mpreg4_fee
                else
                  cost = Config.ch_mpreg5_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_mpreg_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "Provides additional MP recovery for clan members in the clan hall.<font color=\"00FFFF\">#{percent}%</font>"
                html["%apply%"] = "recovery mp #{percent}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_exp")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Chandelier (EXP Recovery Device)"
                percent = val.to_i
                case percent
                when 5
                  cost = Config.ch_expreg1_fee
                when 10
                  cost = Config.ch_expreg2_fee
                when 15
                  cost = Config.ch_expreg3_fee
                when 25
                  cost = Config.ch_expreg4_fee
                when 35
                  cost = Config.ch_expreg5_fee
                when 40
                  cost = Config.ch_expreg6_fee
                else
                  cost = Config.ch_expreg7_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_expreg_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "Restores the Exp of any clan member who is resurrected in the clan hall.<font color=\"00FFFF\">#{percent}%</font>"
                html["%apply%"] = "recovery exp #{percent}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("hp")
                if st.size >= 1
                  if Config.debug
                    debug "Mp editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_HP)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "#{val}%"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  percent = val.to_i
                  case percent
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 20
                    fee = Config.ch_hpreg1_fee
                  when 40
                    fee = Config.ch_hpreg2_fee
                  when 80
                    fee = Config.ch_hpreg3_fee
                  when 100
                    fee = Config.ch_hpreg4_fee
                  when 120
                    fee = Config.ch_hpreg5_fee
                  when 140
                    fee = Config.ch_hpreg6_fee
                  when 160
                    fee = Config.ch_hpreg7_fee
                  when 180
                    fee = Config.ch_hpreg8_fee
                  when 200
                    fee = Config.ch_hpreg9_fee
                  when 220
                    fee = Config.ch_hpreg10_fee
                  when 240
                    fee = Config.ch_hpreg11_fee
                  when 260
                    fee = Config.ch_hpreg12_fee
                  else
                    fee = Config.ch_hpreg13_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_RESTORE_HP, percent, fee, Config.ch_hpreg_fee_ratio, clan_hall.get_function(ClanHall::FUNC_RESTORE_HP).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("mp")
                if st.size >= 1
                  if Config.debug
                    debug "Mp editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_MP)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "#{val}%"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  percent = val.to_i
                  case percent
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 5
                    fee = Config.ch_mpreg1_fee
                  when 10
                    fee = Config.ch_mpreg2_fee
                  when 15
                    fee = Config.ch_mpreg3_fee
                  when 30
                    fee = Config.ch_mpreg4_fee
                  else
                    fee = Config.ch_mpreg5_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_RESTORE_MP, percent, fee, Config.ch_mpreg_fee_ratio, clan_hall.get_function(ClanHall::FUNC_RESTORE_MP).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("exp")
                if st.size >= 1
                  if Config.debug
                    debug "Exp editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_EXP)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "#{val}%"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  percent = val.to_i
                  case percent
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 5
                    fee = Config.ch_expreg1_fee
                  when 10
                    fee = Config.ch_expreg2_fee
                  when 15
                    fee = Config.ch_expreg3_fee
                  when 25
                    fee = Config.ch_expreg4_fee
                  when 35
                    fee = Config.ch_expreg5_fee
                  when 40
                    fee = Config.ch_expreg6_fee
                  else
                    fee = Config.ch_expreg7_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_RESTORE_EXP, percent, fee, Config.ch_expreg_fee_ratio, clan_hall.get_function(ClanHall::FUNC_RESTORE_EXP).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              end
            end
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/clanHallManager/edit_recovery.htm")
            hp_grade0 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 20\">20%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 40\">40%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 220\">220%</a>]"
            hp_grade1 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 40\">40%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 100\">100%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 160\">160%</a>]"
            hp_grade2 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 80\">80%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 140\">140%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 200\">200%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 260\">260%</a>]"
            hp_grade3 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 80\">80%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 120\">120%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 180\">180%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 240\">240%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_hp 300\">300%</a>]"
            exp_grade0 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 5\">5%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 10\">10%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 25\">25%</a>]"
            exp_grade1 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 5\">5%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 15\">15%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 30\">30%</a>]"
            exp_grade2 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 5\">5%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 15\">15%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 25\">25%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 40\">40%</a>]"
            exp_grade3 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 15\">15%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 25\">25%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 35\">35%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_exp 50\">50%</a>]"
            mp_grade0 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 5\">5%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 10\">10%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 25\">25%</a>]"
            mp_grade1 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 5\">5%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 15\">15%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 25\">25%</a>]"
            mp_grade2 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 5\">5%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 15\">15%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 30\">30%</a>]"
            mp_grade3 = "[<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 5\">5%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 15\">15%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 30\">30%</a>][<a action=\"bypass -h npc_%objectId%_manage recovery edit_mp 40\">40%</a>]"
            if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_HP)
              html["%hp_recovery%"] = "#{fn.lvl}%</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_hpreg_fee_ratio / 1000 / 60 / 60 / 24} Day)"
              html["%hp_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_hp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery hp_cancel\">Deactivate</a>]#{hp_grade0}"
              when 1
                html["%change_hp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery hp_cancel\">Deactivate</a>]#{hp_grade1}"
              when 2
                html["%change_hp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery hp_cancel\">Deactivate</a>]#{hp_grade2}"
              when 3
                html["%change_hp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery hp_cancel\">Deactivate</a>]#{hp_grade3}"
              end
            else
              html["%hp_recovery%"] = "none"
              html["%hp_period%"] = "none"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_hp%"] = hp_grade0
              when 1
                html["%change_hp%"] = hp_grade1
              when 2
                html["%change_hp%"] = hp_grade2
              when 3
                html["%change_hp%"] = hp_grade3
              end
            end
            if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_EXP)
              html["%exp_recovery%"] = "#{fn.lvl}%</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_expreg_fee_ratio / 1000 / 60 / 60 / 24} Day)"
              html["%exp_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_exp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery exp_cancel\">Deactivate</a>]#{exp_grade0}"
              when 1
                html["%change_exp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery exp_cancel\">Deactivate</a>]#{exp_grade1}"
              when 2
                html["%change_exp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery exp_cancel\">Deactivate</a>]#{exp_grade2}"
              when 3
                html["%change_exp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery exp_cancel\">Deactivate</a>]#{exp_grade3}"
              end
            else
              html["%exp_recovery%"] = "none"
              html["%exp_period%"] = "none"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_exp%"] = exp_grade0
              when 1
                html["%change_exp%"] = exp_grade1
              when 2
                html["%change_exp%"] = exp_grade2
              when 3
                html["%change_exp%"] = exp_grade3
              end
            end
            if fn = clan_hall.get_function(ClanHall::FUNC_RESTORE_MP)
              html["%mp_recovery%"] = "#{fn.lvl}%</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_mpreg_fee_ratio / 1000 / 60 / 60 / 24} Day)"
              html["%mp_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_mp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery mp_cancel\">Deactivate</a>]#{mp_grade0}"
              when 1
                html["%change_mp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery mp_cancel\">Deactivate</a>]#{mp_grade1}"
              when 2
                html["%change_mp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery mp_cancel\">Deactivate</a>]#{mp_grade2}"
              when 3
                html["%change_mp%"] = "[<a action=\"bypass -h npc_%objectId%_manage recovery mp_cancel\">Deactivate</a>]#{mp_grade3}"
              end
            else
              html["%mp_recovery%"] = "none"
              html["%mp_period%"] = "none"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_mp%"] = mp_grade0
              when 1
                html["%change_mp%"] = mp_grade1
              when 2
                html["%change_mp%"] = mp_grade2
              when 3
                html["%change_mp%"] = mp_grade3
              end
            end
            send_html_message(pc, html)
          elsif val.casecmp?("other")
            if st.size >= 1
              if clan_hall.owner_id == 0
                pc.send_message("This clan hall has no owner, you cannot change the configuration.")
                return
              end
              val = st.shift
              if val.casecmp?("item_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "other item 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("tele_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "other tele 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("support_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "other support 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_item")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Magic Equipment (Item Production Facilities)"
                stage = val.to_i
                case stage
                when 1
                  cost = Config.ch_item1_fee
                when 2
                  cost = Config.ch_item2_fee
                else
                  cost = Config.ch_item3_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_item_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "Allow the purchase of special items at fixed intervals."
                html["%apply%"] = "other item #{stage}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_support")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Insignia (Supplementary Magic)"
                stage = val.to_i
                case stage
                when 1
                  cost = Config.ch_support1_fee
                when 2
                  cost = Config.ch_support2_fee
                when 3
                  cost = Config.ch_support3_fee
                when 4
                  cost = Config.ch_support4_fee
                when 5
                  cost = Config.ch_support5_fee
                when 6
                  cost = Config.ch_support6_fee
                when 7
                  cost = Config.ch_support7_fee
                else
                  cost = Config.ch_support8_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_support_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "Enables the use of supplementary magic."
                html["%apply%"] = "other support #{stage}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_tele")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Mirror (Teleportation Device)"
                stage = val.to_i
                case stage
                when 1
                  cost = Config.ch_tele1_fee
                else
                  cost = Config.ch_tele2_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_tele_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "Teleports clan members in a clan hall to the target <font color=\"00FFFF\">Stage #{stage}</font> staging area"
                html["%apply%"] = "other tele #{stage}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("item")
                if st.size >= 1
                  if clan_hall.owner_id == 0
                    pc.send_message("This clan hall has no owner, you cannot change the configuration.")
                    return
                  end
                  if Config.debug
                    debug "Item editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_ITEM_CREATE)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "Stage #{val}"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  lvl = val.to_i
                  case lvl
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 1
                    fee = Config.ch_item1_fee
                  when 2
                    fee = Config.ch_item2_fee
                  else
                    fee = Config.ch_item3_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_ITEM_CREATE, lvl, fee, Config.ch_item_fee_ratio, clan_hall.get_function(ClanHall::FUNC_ITEM_CREATE).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("tele")
                if st.size >= 1
                  if Config.debug
                    debug "Tele editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_TELEPORT)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "Stage #{val}"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  lvl = val.to_i
                  case lvl
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 1
                    fee = Config.ch_tele1_fee
                  else
                    fee = Config.ch_tele2_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_TELEPORT, lvl, fee, Config.ch_tele_fee_ratio, clan_hall.get_function(ClanHall::FUNC_TELEPORT).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("support")
                if st.size >= 1
                  if Config.debug
                    debug "Support editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_SUPPORT)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "Stage #{val}"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  lvl = val.to_i
                  case lvl
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 1
                    fee = Config.ch_support1_fee
                  when 2
                    fee = Config.ch_support2_fee
                  when 3
                    fee = Config.ch_support3_fee
                  when 4
                    fee = Config.ch_support4_fee
                  when 5
                    fee = Config.ch_support5_fee
                  when 6
                    fee = Config.ch_support6_fee
                  when 7
                    fee = Config.ch_support7_fee
                  else
                    fee = Config.ch_support8_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_SUPPORT, lvl, fee, Config.ch_support_fee_ratio, clan_hall.get_function(ClanHall::FUNC_SUPPORT).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              end
            end
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/clanHallManager/edit_other.htm")
            tele = "[<a action=\"bypass -h npc_%objectId%_manage other edit_tele 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_tele 2\">Level 2</a>]"
            support_grade0 = "[<a action=\"bypass -h npc_%objectId%_manage other edit_support 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 2\">Level 2</a>]"
            support_grade1 = "[<a action=\"bypass -h npc_%objectId%_manage other edit_support 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 2\">Level 2</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 4\">Level 4</a>]"
            support_grade2 = "[<a action=\"bypass -h npc_%objectId%_manage other edit_support 3\">Level 3</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 4\">Level 4</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 5\">Level 5</a>]"
            support_grade3 = "[<a action=\"bypass -h npc_%objectId%_manage other edit_support 3\">Level 3</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 5\">Level 5</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 7\">Level 7</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_support 8\">Level 8</a>]"
            item = "[<a action=\"bypass -h npc_%objectId%_manage other edit_item 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_item 2\">Level 2</a>][<a action=\"bypass -h npc_%objectId%_manage other edit_item 3\">Level 3</a>]"
            if fn = clan_hall.get_function(ClanHall::FUNC_TELEPORT)
              html["%tele%"] = "Stage #{fn.lvl}</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_tele_fee_ratio / 1000 / 60 / 60 / 24} Day)"
              html["%tele_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              html["%change_tele%"] = "[<a action=\"bypass -h npc_%objectId%_manage other tele_cancel\">Deactivate</a>]#{tele}"
            else
              html["%tele%"] = "none"
              html["%tele_period%"] = "none"
              html["%change_tele%"] = tele
            end
            if fn = clan_hall.get_function(ClanHall::FUNC_SUPPORT)
              html["%support%"] = "Stage #{fn.lvl}</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_support_fee_ratio / 1000 / 60 / 60 / 24} Day"
              html["%support_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_support%"] = "[<a action=\"bypass -h npc_%objectId%_manage other support_cancel\">Deactivate</a>]#{support_grade0}"
              when 1
                html["%change_support%"] = "[<a action=\"bypass -h npc_%objectId%_manage other support_cancel\">Deactivate</a>]#{support_grade1}"
              when 2
                html["%change_support%"] = "[<a action=\"bypass -h npc_%objectId%_manage other support_cancel\">Deactivate</a>]#{support_grade2}"
              when 3
                html["%change_support%"] = "[<a action=\"bypass -h npc_%objectId%_manage other support_cancel\">Deactivate</a>]#{support_grade3}"
              end
            else
              html["%support%"] = "none"
              html["%support_period%"] = "none"
              grade = clan_hall.grade
              case grade
              when 0
                html["%change_support%"] = support_grade0
              when 1
                html["%change_support%"] = support_grade1
              when 2
                html["%change_support%"] = support_grade2
              when 3
                html["%change_support%"] = support_grade3
              end
            end
            if fn = clan_hall.get_function(ClanHall::FUNC_ITEM_CREATE)
              html["%item%"] = "Stage #{fn.lvl}</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_item_fee_ratio / 1000 / 60 / 60 / 24} Day)"
              html["%item_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              html["%change_item%"] = "[<a action=\"bypass -h npc_%objectId%_manage other item_cancel\">Deactivate</a>]#{item}"
            else
              html["%item%"] = "none"
              html["%item_period%"] = "none"
              html["%change_item%"] = item
            end
            send_html_message(pc, html)
          elsif val.casecmp?("deco") && !clan_hall.siegable_hall?
            if st.size >= 1
              if clan_hall.owner_id == 0
                pc.send_message("This clan hall has no owner, you cannot change the configuration.")
                return
              end
              val = st.shift
              if val.casecmp?("curtains_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "deco curtains 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("fixtures_cancel")
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-cancel.htm")
                html["%apply%"] = "deco fixtures 0"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_curtains")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Curtains (Decoration)"
                stage = val.to_i
                case stage
                when 1
                  cost = Config.ch_curtain1_fee
                else
                  cost = Config.ch_curtain2_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_curtain_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "These curtains can be used to decorate the clan hall."
                html["%apply%"] = "deco curtains #{stage}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("edit_fixtures")
                val = st.shift
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/functions-apply.htm")
                html["%name%"] = "Front Platform (Decoration)"
                stage = val.to_i
                case stage
                when 1
                  cost = Config.ch_front1_fee
                else
                  cost = Config.ch_front2_fee
                end
                html["%cost%"] = "#{cost}</font>Adena /#{Config.ch_front_fee_ratio / 1000 / 60 / 60 / 24} Day</font>)"
                html["%use%"] = "Used to decorate the clan hall."
                html["%apply%"] = "deco fixtures #{stage}"
                send_html_message(pc, html)
                return
              elsif val.casecmp?("curtains")
                if st.size >= 1
                  if Config.debug
                    debug "Deco curtains editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_DECO_CURTAINS)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "Stage #{val}"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  lvl = val.to_i
                  case lvl
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 1
                    fee = Config.ch_curtain1_fee
                  else
                    fee = Config.ch_curtain2_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_DECO_CURTAINS, lvl, fee, Config.ch_curtain_fee_ratio, clan_hall.get_function(ClanHall::FUNC_DECO_CURTAINS).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              elsif val.casecmp?("fixtures")
                if st.size >= 1
                  if Config.debug
                    debug "Deco fixtures editing invoked"
                  end
                  val = st.shift
                  html = NpcHtmlMessage.new(l2id)
                  html.set_file(pc, "data/html/clanHallManager/functions-apply_confirmed.htm")
                  if fn = clan_hall.get_function(ClanHall::FUNC_DECO_FRONTPLATEFORM)
                    if fn.lvl == val.to_i
                      html.set_file(pc, "data/html/clanHallManager/functions-used.htm")
                      html["%val%"] = "Stage #{val}"
                      send_html_message(pc, html)
                      return
                    end
                  end
                  lvl = val.to_i
                  case lvl
                  when 0
                    fee = 0
                    html.set_file(pc, "data/html/clanHallManager/functions-cancel_confirmed.htm")
                  when 1
                    fee = Config.ch_front1_fee
                  else
                    fee = Config.ch_front2_fee
                  end
                  if !clan_hall.update_functions(pc, ClanHall::FUNC_DECO_FRONTPLATEFORM, lvl, fee, Config.ch_front_fee_ratio, clan_hall.get_function(ClanHall::FUNC_DECO_FRONTPLATEFORM).nil?)
                    html.set_file(pc, "data/html/clanHallManager/low_adena.htm")
                    send_html_message(pc, html)
                  else
                    revalidate_deco(pc)
                  end
                  send_html_message(pc, html)
                end
                return
              end
            end
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/clanHallManager/deco.htm")
            curtains = "[<a action=\"bypass -h npc_%objectId%_manage deco edit_curtains 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage deco edit_curtains 2\">Level 2</a>]"
            fixtures = "[<a action=\"bypass -h npc_%objectId%_manage deco edit_fixtures 1\">Level 1</a>][<a action=\"bypass -h npc_%objectId%_manage deco edit_fixtures 2\">Level 2</a>]"
            if fn = clan_hall.get_function(ClanHall::FUNC_DECO_CURTAINS)
              html["%curtain%"] = "Stage #{fn.lvl}</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_curtain_fee_ratio / 1000 / 60 / 60 / 24} Day)"
              html["%curtain_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              html["%change_curtain%"] = "[<a action=\"bypass -h npc_%objectId%_manage deco curtains_cancel\">Deactivate</a>]#{curtains}"
            else
              html["%curtain%"] = "none"
              html["%curtain_period%"] = "none"
              html["%change_curtain%"] = curtains
            end
            if fn = clan_hall.get_function(ClanHall::FUNC_DECO_FRONTPLATEFORM)
              html["%fixture%"] = "Stage #{fn.lvl}</font> (<font color=\"FFAABB\">#{fn.lease}</font>Adena /#{Config.ch_front_fee_ratio / 1000 / 60 / 60 / 24} Day)"
              html["%fixture_period%"] = "Withdraw the fee for the next time at #{Time.from_ms(fn.end_time).to_s(format)}"
              html["%change_fixture%"] = "[<a action=\"bypass -h npc_%objectId%_manage deco fixtures_cancel\">Deactivate</a>]#{fixtures}"
            else
              html["%fixture%"] = "none"
              html["%fixture_period%"] = "none"
              html["%change_fixture%"] = fixtures
            end
            send_html_message(pc, html)
          elsif val.casecmp?("back")
            show_chat_window(pc)
          else
            html = NpcHtmlMessage.new(l2id)
            if clan_hall.siegable_hall?
              html.set_file(pc, "data/html/clanHallManager/manage_siegable.htm")
            else
              html.set_file(pc, "data/html/clanHallManager/manage.htm")
            end
            send_html_message(pc, html)
          end
        else
          html = NpcHtmlMessage.new(1)
          html.set_file(pc, "data/html/clanHallManager/not_authorized.htm")
          send_html_message(pc, html)
        end
        return
      elsif actual_command.casecmp?("support")
        if pc.cursed_weapon_equipped?
          pc.send_message("The wielder of a cursed weapon cannot receive outside heals or buffs")
          return
        end

        if val.empty?
          return
        end

        self.target = pc

        begin
          skill_id = val.to_i
          begin
            skill_lvl = 0
            unless st.empty?
              skill_lvl = st.shift.to_i
            end
            skill = SkillData[skill_id, skill_lvl]
            if skill.has_effect_type?(L2EffectType::SUMMON)
              pc.do_simultaneous_cast(skill)
            else
              mp_cost = skill.mp_consume1 + skill.mp_consume2
              if current_mp >= mp_cost || Config.ch_buff_free
                do_cast(skill)
              else
                html = NpcHtmlMessage.new(l2id)
                html.set_file(pc, "data/html/clanHallManager/support-no_mana.htm")
                html["%mp%"] = current_mp.to_i
                send_html_message(pc, html)
                return
              end
            end

            unless fn = clan_hall.get_function(ClanHall::FUNC_SUPPORT)
              return
            end

            if fn.lvl == 0
              return
            end
            html = NpcHtmlMessage.new(l2id)
            html.set_file(pc, "data/html/clanHallManager/support-done.htm")
            html["%mp%"] = current_mp.to_i
            send_html_message(pc, html)
          rescue e
            error e
            pc.send_message("Invalid skill level.")
          end
        rescue e
          error e
          pc.send_message("Invalid skill level.")
        end

        return
      elsif actual_command.casecmp?("list_back")
        html = NpcHtmlMessage.new(l2id)
        file = "data/html/clanHallManager/chamberlain-#{id}.htm"
        unless HtmCache.loadable?(file)
          file = "data/html/clanHallManager/chamberlain.htm"
        end

        html.set_file(pc, file)
        html["%objectId%"] = l2id
        html["%npcname%"] = name
        send_html_message(pc, html)
        return
      elsif actual_command.casecmp?("support_back")
        fn = clan_hall.get_function(ClanHall::FUNC_SUPPORT).not_nil!
        if fn.lvl == 0
          return
        end
        html = NpcHtmlMessage.new(l2id)
        html.set_file(pc, "data/html/clanHallManager/support#{fn.lvl}.htm")
        html["%mp%"] = current_mp.to_i
        send_html_message(pc, html)
        return
      elsif actual_command.casecmp?("goto")
        where = val.to_i
        do_teleport(pc, where)
        return
      end
    end


    super
  end

  private def send_html_message(pc : L2PcInstance, html : NpcHtmlMessage)
    html["%objectId%"] = l2id
    html["%npcId%"] = id
    pc.send_packet(html)
  end

  def show_chat_window(pc : L2PcInstance)
    pc.action_failed

    filename = "data/html/clanHallManager/chamberlain-no.htm"
    condition = validate_condition(pc)
    if condition == COND_OWNER
      filename = "data/html/clanHallManager/chamberlain-#{id}.htm"
      unless HtmCache.loadable?(filename)
        filename = "data/html/clanHallManager/chamberlain.htm"
      end
    elsif condition == COND_ALL_FALSE
      filename = "data/html/clanHallManager/chamberlain-of.htm"
    end

    html = NpcHtmlMessage.new(l2id)
    html.set_file(pc, filename)
    html["%objectId%"] = l2id
    html["%npcId%"] = id
    pc.send_packet(html)
  end

  private def validate_condition(pc : L2PcInstance) : Int32
    unless clan_hall?
      return COND_ALL_FALSE
    end

    if pc.override_clanhall_conditions?
      return COND_OWNER
    end

    if pc.clan?
      if clan_hall.owner_id == pc.clan_id
        return COND_OWNER
      end

      return COND_OWNER_FALSE
    end

    COND_ALL_FALSE
  end

  def clan_hall? : ClanHall?
    if @clan_hall_id < 0
      unless tmp = ClanHallManager.get_nearby_clan_hall(x, y, 500)
        tmp = ClanHallSiegeManager.get_nearby_clan_hall(self)
      end

      if tmp
        @clan_hall_id = tmp.id
      end

      if @clan_hall_id < 0
        return
      end
    end

    ClanHallManager.get_clan_hall_by_id(@clan_hall_id)
  end

  def clan_hall : ClanHall
    unless ch = clan_hall?
      raise "This #{self.class} has no clan hall."
    end

    ch
  end

  private def do_teleport(pc : L2PcInstance, val : Int32)
    if Config.debug
      debug "L2ClanHallManagerInstance#do_teleport(#{pc}, #{val})"
    end

    if list = TeleportLocationTable[val]?
      if pc.combat_flag_equipped?
        pc.send_packet(SystemMessageId::YOU_CANNOT_TELEPORT_WHILE_IN_POSSESSION_OF_A_WARD)
        return
      elsif pc.destroy_item_by_item_id("Teleport", list.item_id, list.price.to_i64, self, true)
        if Config.debug
          debug "Teleporting player #{pc.name} from CH to #{list.x}, #{list.y}, #{list.z}."
        end
      end
    else
      warn "No teleport destination with id #{val}."
    end

    pc.action_failed
  end

  private def revalidate_deco(pc : L2PcInstance)
    unless ch = ClanHallManager.get_clan_hall_by_owner(pc.clan)
      return
    end

    pc.send_packet(AgitDecoInfo.new(ch))
  end
end
