class Scripts::CastleChamberlain < AbstractNpcAI
  # NPCs
  private NPC = {
    35100, # Sayres
    35142, # Crosby
    35184, # Saul
    35226, # Brasseur
    35274, # Logan
    35316, # Neurath
    35363, # Alfred
    35509, # Frederick
    35555  # August
  }
  # Item
  private CROWN = 6841
  # Fortress
  private FORTRESS = {
    1 => [101, 102, 112, 113], # Gludio Castle
    2 => [103, 112, 114, 115], # Dion Castle
    3 => [104, 114, 116, 118, 119], # Giran Castle
    4 => [105, 113, 115, 116, 117], # Oren Castle
    5 => [106, 107, 117, 118], # Aden Castle
    6 => [108, 119], # Innadril Castle
    7 => [109, 117, 120], # Goddard Castle
    8 => [110, 120, 121], # Rune Castle
    9 => [111, 121] # Schuttgart Castle
  }

  # Buffs
  private BUFFS = {
    SkillHolder.new(4342, 2), # Wind Walk Lv.2
    SkillHolder.new(4343, 3), # Decrease Weight Lv.3
    SkillHolder.new(4344, 3), # Shield Lv.3
    SkillHolder.new(4346, 4), # Mental Shield Lv.4
    SkillHolder.new(4345, 3), # Might Lv.3
    SkillHolder.new(4347, 2), # Bless the Body Lv.2
    SkillHolder.new(4349, 1), # Magic Barrier Lv.1
    SkillHolder.new(4350, 1), # Resist Shock Lv.1
    SkillHolder.new(4348, 2), # Bless the Soul Lv.2
    SkillHolder.new(4351, 2), # Concentration Lv.2
    SkillHolder.new(4352, 1), # Berserker Spirit Lv.1
    SkillHolder.new(4353, 2), # Bless Shield Lv.2
    SkillHolder.new(4358, 1), # Guidance Lv.1
    SkillHolder.new(4354, 1), # Vampiric Rage Lv.1
    SkillHolder.new(4347, 6), # Bless the Body Lv.6
    SkillHolder.new(4349, 2), # Magic Barrier Lv.2
    SkillHolder.new(4350, 4), # Resist Shock Lv.4
    SkillHolder.new(4348, 6), # Bless the Soul Lv.6
    SkillHolder.new(4351, 6), # Concentration Lv.6
    SkillHolder.new(4352, 2), # Berserker Spirit Lv.2
    SkillHolder.new(4353, 6), # Bless Shield Lv.6
    SkillHolder.new(4358, 3), # Guidance Lv.3
    SkillHolder.new(4354, 4), # Vampiric Rage Lv.4
    SkillHolder.new(4355, 1), # Acumen Lv.1
    SkillHolder.new(4356, 1), # Empower Lv.1
    SkillHolder.new(4357, 1), # Haste Lv.1
    SkillHolder.new(4359, 1), # Focus Lv.1
    SkillHolder.new(4360, 1)  # Death Whisper Lv.1
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPC)
    add_talk_id(NPC)
    add_first_talk_id(NPC)
  end

  private def get_html_packet(pc, npc, html_file)
    packet = NpcHtmlMessage.new(npc.l2id)
    packet.html = get_htm(pc, html_file)
    packet
  end

  private def func_confirm_html(pc, npc, castle, func, level)
    if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
      fstring = func == Castle::FUNC_TELEPORT ? "9" : "10"
      if level == 0
        html = get_html_packet(pc, npc, "castleresetdeco.html")
        html["%AgitDecoSubmit%"] = func
      elsif (fn = castle.get_function(func)) && fn.lvl == level
        html = get_html_packet(pc, npc, "castledecoalreadyset.html")
        html["%AgitDecoEffect%"] = "<fstring p1=\"#{level}\">#{fstring}</fstring>"
      else
        html = get_html_packet(pc, npc, "castledeco-0#{func}.html")
        html["%AgitDecoCost%"] = "<fstring p1=\"#{get_function_fee(func, level)}\" p2=\"#{get_function_ratio(func) / 86400000}\">6</fstring>"
        html["%AgitDecoEffect%"] = "<fstring p1=\"#{level}\">#{fstring}</fstring>"
        html["%AgitDecoSubmit%"] = "#{func} #{level}"
      end
      pc.send_packet(html)
      return
    end

    "chamberlain-21.html"
  end

  private def func_replace(castle, html, func, str)
    fn = castle.get_function(func)
    if fn.nil?
      html["%#{str}Depth%"] = "<fstring>4</fstring>"
      html["%#{str}Cost%"] = ""
      html["%#{str}Expire%"] = "<fstring>4</fstring>"
      html["%#{str}Reset%"] = ""
    else
      if func == Castle::FUNC_SUPPORT || func == Castle::FUNC_TELEPORT
        fstring = "9"
      else
        fstring = "10"
      end
      cal = Calendar.new
      cal.ms = fn.end_time
      html["%#{str}Depth%"] = "<fstring p1=\"#{fn.lvl}\">#{fstring}</fstring>"
      html["%#{str}Cost%"] = "<fstring p1=\"#{fn.lease}\" p2=\"#{fn.rate / 86400000}\">6</fstring>"
      html["%#{str}Expire%"] = "<fstring p1=\"#{cal.day}\" p2=\"#{cal.month + 1}\" p3=\"#{cal.year}\">5</fstring>"
      html["%#{str}Reset%"] = "[<a action=\"bypass -h Quest CastleChamberlain #{str} 0\">Deactivate</a>]"
    end
  end

  private def get_function_fee(func, level) : Int32
    case func
    when Castle::FUNC_RESTORE_EXP
      level == 45 ? Config.cs_expreg1_fee : Config.cs_expreg2_fee
    when Castle::FUNC_RESTORE_HP
      level == 300 ? Config.cs_hpreg1_fee : Config.cs_hpreg2_fee
    when Castle::FUNC_RESTORE_MP
      level == 40 ? Config.cs_mpreg1_fee : Config.cs_mpreg2_fee
    when Castle::FUNC_SUPPORT
      level == 5 ? Config.cs_support1_fee : Config.cs_support2_fee
    when Castle::FUNC_TELEPORT
      level == 1 ? Config.cs_tele1_fee : Config.cs_tele2_fee
    else
      0
    end
  end

  private def get_function_ratio(func) : Int64
    case func
    when Castle::FUNC_RESTORE_EXP
      Config.cs_expreg_fee_ratio
    when Castle::FUNC_RESTORE_HP
      Config.cs_hpreg_fee_ratio
    when Castle::FUNC_RESTORE_MP
      Config.cs_mpreg_fee_ratio
    when Castle::FUNC_SUPPORT
      Config.cs_support_fee_ratio
    when Castle::FUNC_TELEPORT
      Config.cs_tele_fee_ratio
    else
      0i64
    end
  end

  private def get_door_upgrade_price(type, level)
    price = 0

    case type
    when 1 # Outer Door
      case level
      when 2
        price = Config.outer_door_upgrade_price2
      when 3
        price = Config.outer_door_upgrade_price3
      when 5
        price = Config.outer_door_upgrade_price5
      else
        # [automatically added else]
      end

    when 2 # Inner Door
      case level
      when 2
        price = Config.inner_door_upgrade_price2
      when 3
        price = Config.inner_door_upgrade_price3
      when 5
        price = Config.inner_door_upgrade_price5
      else
        # [automatically added else]
      end

    when 3 # Wall
      case level
      when 2
        price = Config.wall_upgrade_price2
      when 3
        price = Config.wall_upgrade_price3
      when 5
        price = Config.wall_upgrade_price5
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    case SevenSigns.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_DUSK
      price *= 3
    when SevenSigns::CABAL_DAWN
      price *= 0.8
    else
      # [automatically added else]
    end


    price.to_i
  end

  private def get_seal_owner(seal)
    case SevenSigns.get_seal_owner(seal)
    when SevenSigns::CABAL_DAWN
      "1000511"
    when SevenSigns::CABAL_DUSK
      "1000510"
    else
      "1000512"
    end
  end

  private def tax_limit
    case SevenSigns.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_DAWN
      25
    when SevenSigns::CABAL_DUSK
      5
    else
      15
    end
  end

  private def get_trap_upgrade_price(level)
    price = 0
    case level
    when 1
      price = Config.trap_upgrade_price1
    when 2
      price = Config.trap_upgrade_price2
    when 3
      price = Config.trap_upgrade_price3
    when 4
      price = Config.trap_upgrade_price4
    else
      # [automatically added else]
    end


    case SevenSigns.get_seal_owner(SevenSigns::SEAL_STRIFE)
    when SevenSigns::CABAL_DUSK
      price *= 3
    when SevenSigns::CABAL_DAWN
      price *= 0.8
    else
      # [automatically added else]
    end


    price.to_i
  end

  private def domain_fortress_in_contract_status?(castle_id)
    FORTRESS[castle_id].any? do |fort_id|
      FortManager.get_fort_by_id(fort_id).not_nil!.fort_state == 2
    end
  end

  private def owner?(pc,  npc)
    pc.override_castle_conditions? ||
    (!!pc.clan && pc.clan_id == npc.castle.owner_id)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    castle = npc.castle
    st = event.split

    case st.shift
    when "chamberlain-01.html", "manor-help-01.html", "manor-help-02.html",
         "manor-help-03.html", "manor-help-04.html"
      htmltext = event
    when "fort_status"
      if npc.my_lord?(pc)
        sb = String.build do |io|
          forts = FORTRESS[castle.residence_id]
          forts.each do |id|
            fortress = FortManager.get_fort_by_id(id).not_nil!
            fort_id = fortress.residence_id
            fort_type = fort_id < 112 ? "1300133" : "1300134"
            case fortress.fort_state
            when 1
              fort_status = "1300122"
            when 2
              fort_status = "1300124"
            else
              fort_status = "1300123"
            end
            io << "<fstring>1300"
            io << fort_id
            io << "</fstring>"
            io << " (<fstring>"
            io << fort_type
            io << "</fstring>)"
            io << " : <font color=\"00FFFF\"><fstring>"
            io << fort_status
            io << "</fstring></font><br>"
          end
        end
        html = get_html_packet(pc, npc, "chamberlain-28.html")
        html["%list%"] = sb
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "siege_functions"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        if castle.siege.in_progress?
          htmltext = "chamberlain-08.html"
        elsif !domain_fortress_in_contract_status?(castle.residence_id)
          htmltext = "chamberlain-27.html"
        elsif !SevenSigns.comp_results_period?
          htmltext = "chamberlain-26.html"
        else
          htmltext = "chamberlain-12.html"
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "manage_doors"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        if !st.empty?
          html = get_html_packet(pc, npc, "chamberlain-13.html")
          html["%type%"] = st.shift
          sb = String.build do |io|
            until st.empty?
              io << st.shift
            end
          end
          html["%doors%"] = sb
          pc.send_packet(html)
        else
          htmltext = "#{npc.id}-du.html"
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "upgrade_doors"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        type = st.shift.to_i
        level = st.shift.to_i
        html = get_html_packet(pc, npc, "chamberlain-14.html")
        html["%gate_price%"] = get_door_upgrade_price(type, level)
        html["%event%"] = event.from("upgrade_doors".size + 1)
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "upgrade_doors_confirm"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        if castle.siege.in_progress?
          htmltext = "chamberlain-08.html"
        else
          type = st.shift.to_i
          level = st.shift.to_i
          price = get_door_upgrade_price(type, level)
          doors = Slice.new(2, 0)
          st.each_with_index do |token, i|
            doors[i] = token.to_i
          end

          if door = castle.get_door(doors[0])
            current_level = door.stat.upgrade_hp_ratio
            if current_level >= level
              html = get_html_packet(pc, npc, "chamberlain-15.html")
              html["%doorlevel%"] = current_level
              pc.send_packet(html)
            elsif pc.adena >= price
              take_items(pc, Inventory::ADENA_ID, price)
              doors.each do |door_id|
                castle.set_door_upgrade(door_id, level, true)
              end
              htmltext = "chamberlain-16.html"
            else
              htmltext = "chamberlain-09.html"
            end
          end
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "manage_trap"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        if !st.empty?
          if castle.name.casecmp?("aden")
            html = get_html_packet(pc, npc, "chamberlain-17a.html")
          else
            html = get_html_packet(pc, npc, "chamberlain-17.html")
          end
          html["%trapIndex%"] = st.shift
          pc.send_packet(html)
        else
          htmltext = "#{npc.id}-tu.html"
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "upgrade_trap"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        trap_index = st.shift
        level = st.shift.to_i
        html = get_html_packet(pc, npc, "chamberlain-18.html")
        html["%trapIndex%"] = trap_index
        html["%level%"] = level
        html["%dmgzone_price%"] = get_trap_upgrade_price(level)
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "upgrade_trap_confirm"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        if castle.siege.in_progress?
          htmltext = "chamberlain-08.html"
        else
          trap_index = st.shift.to_i
          level = st.shift.to_i
          price = get_trap_upgrade_price(level)
          current_level = castle.get_trap_upgrade_level(trap_index)

          if current_level >= level
            html = get_html_packet(pc, npc, "chamberlain-19.html")
            html["%dmglevel%"] = current_level
            pc.send_packet(html)
          elsif pc.adena >= price
            take_items(pc, Inventory::ADENA_ID, price)
            castle.set_trap_upgrade(trap_index, level, true)
            htmltext = "chamberlain-20.html"
          else
            htmltext = "chamberlain-09.html"
          end
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "receive_report"
      if npc.my_lord?(pc)
        if castle.siege.in_progress?
          htmltext = "chamberlain-07.html"
        else
          clan = ClanTable.get_clan(castle.owner_id).not_nil!
          html = get_html_packet(pc, npc, "chamberlain-02.html")
          html["%clanleadername%"] = clan.leader_name
          html["%clanname%"] = clan.name
          html["%castlename%"] = 1001000 + castle.residence_id

          case SevenSigns.current_period
          when SevenSigns::PERIOD_COMP_RECRUITING
            html["%ss_event%"] = "1000509"
          when SevenSigns::PERIOD_COMPETITION
            html["%ss_event%"] = "1000507"
          when SevenSigns::PERIOD_SEAL_VALIDATION, SevenSigns::PERIOD_COMP_RESULTS
            html["%ss_event%"] = "1000508"
          else
            # [automatically added else]
          end

          html["%ss_avarice%"] = get_seal_owner(1)
          html["%ss_gnosis%"] = get_seal_owner(2)
          html["%ss_strife%"] = get_seal_owner(3)
          pc.send_packet(html)
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "manage_tax"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_TAXES)
        if castle.siege.in_progress?
          htmltext = "chamberlain-08.html"
        else
          html = get_html_packet(pc, npc, "castlesettaxrate.html")
          html["%tax_rate%"] = castle.tax_percent
          html["%next_tax_rate%"] = "0" # TODO: Implement me
          html["%tax_limit%"] = tax_limit
          pc.send_packet(html)
        end
      elsif owner?(pc, npc)
        html = get_html_packet(pc, npc, "chamberlain-03.html")
        html["%tax_rate%"] = castle.tax_percent
        html["%next_tax_rate%"] = "0" # TODO: Implement me
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "set_tax"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_TAXES)
        if castle.siege.in_progress?
          htmltext = "chamberlain-08.html"
        else
          tax = st.empty? ? 0 : st.shift.to_i
          tax_limit = tax_limit()
          if tax > tax_limit
            html = get_html_packet(pc, npc, "castletoohightaxrate.html")
            html["%tax_limit%"] = tax_limit
          else
            castle.tax_percent = tax
            html = get_html_packet(pc, npc, "castleaftersettaxrate.html")
            html["%next_tax_rate%"] = tax
          end
          pc.send_packet(html)
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "manage_vault"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_TAXES)
        seed_income = 0i64
        if Config.allow_manor
          CastleManorManager.get_seed_production(castle.residence_id, false).each do |sp|
            diff = sp.start_amount - sp.amount
            if diff != 0
              seed_income += diff * sp.price
            end
          end
        end

        html = get_html_packet(pc, npc, "castlemanagevault.html")
        html["%tax_income%"] = Util.format_adena(castle.treasury)
        html["%tax_income_reserved%"] = "0" # TODO: Implement me
        html["%seed_income%"] = Util.format_adena(seed_income)
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "deposit"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_TAXES)
        amount = st.empty? ? 0i64 : st.shift.to_i64
        if amount > 0 && amount < Inventory.max_adena
          if pc.adena >= amount
            take_items(pc, Inventory::ADENA_ID, amount)
            castle.add_to_treasury_no_tax(amount)
          else
            pc.send_packet(SystemMessageId::YOU_NOT_ENOUGH_ADENA)
          end
        end
        htmltext = "chamberlain-01.html"
      else
        htmltext = "chamberlain-21.html"
      end
    when "withdraw"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_TAXES)
        amount = st.empty? ? 0i64 : st.shift.to_i64
        if amount <= castle.treasury
          castle.add_to_treasury_no_tax(-1i64 * amount)
          give_adena(pc, amount, false)
          htmltext = "chamberlain-01.html"
        else
          html = get_html_packet(pc, npc, "castlenotenoughbalance.html")
          html["%tax_income%"] = Util.format_adena(castle.treasury)
          html["%withdraw_amount%"] = Util.format_adena(amount)
          pc.send_packet(html)
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "manage_functions"
      if !owner?(pc, npc)
        htmltext = "chamberlain-21.html"
      elsif castle.siege.in_progress?
        htmltext = "chamberlain-08.html"
      else
        htmltext = "chamberlain-23.html"
      end
    when "banish_foreigner_show"
      if !owner?(pc, npc) || !pc.has_clan_privilege?(ClanPrivilege::CS_DISMISS)
        htmltext = "chamberlain-21.html"
      elsif castle.siege.in_progress?
        htmltext = "chamberlain-08.html"
      else
        htmltext = "chamberlain-10.html"
      end
    when "banish_foreigner"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_DISMISS)
        if castle.siege.in_progress? || TerritoryWarManager.tw_in_progress?
          htmltext = "chamberlain-08.html"
        else
          castle.banish_foreigners
          htmltext = "chamberlain-11.html"
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "doors"
      if !owner?(pc, npc) || !pc.has_clan_privilege?(ClanPrivilege::CS_OPEN_DOOR)
        htmltext = "chamberlain-21.html"
      elsif castle.siege.in_progress?
        htmltext = "chamberlain-08.html"
      else
        htmltext = "#{npc.id}-d.html"
      end
    when "operate_door"
      if !owner?(pc, npc) || !pc.has_clan_privilege?(ClanPrivilege::CS_OPEN_DOOR)
        htmltext = "chamberlain-21.html"
      elsif castle.siege.in_progress?
        htmltext = "chamberlain-08.html"
      else
        open = st.shift.to_i == 1
        until st.empty?
          castle.open_close_door(pc, st.shift.to_i, open)
        end
        htmltext = open ? "chamberlain-05.html" : "chamberlain-06.html"
      end
    when "additional_functions"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        htmltext = "castletdecomanage.html"
      else
        htmltext = "chamberlain-21.html"
      end
    when "recovery"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        html = get_html_packet(pc, npc, "castledeco-AR01.html")
        func_replace(castle, html, Castle::FUNC_RESTORE_HP, "HP")
        func_replace(castle, html, Castle::FUNC_RESTORE_MP, "MP")
        func_replace(castle, html, Castle::FUNC_RESTORE_EXP, "XP")
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "other"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        html = get_html_packet(pc, npc, "castledeco-AE01.html")
        func_replace(castle, html, Castle::FUNC_TELEPORT, "TP")
        func_replace(castle, html, Castle::FUNC_SUPPORT, "BF")
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "HP"
      level = st.shift.to_i
      htmltext = func_confirm_html(pc, npc, castle, Castle::FUNC_RESTORE_HP, level)
    when "MP"
      level = st.shift.to_i
      htmltext = func_confirm_html(pc, npc, castle, Castle::FUNC_RESTORE_MP, level)
    when "XP"
      level = st.shift.to_i
      htmltext = func_confirm_html(pc, npc, castle, Castle::FUNC_RESTORE_EXP, level)
    when "TP"
      level = st.shift.to_i
      htmltext = func_confirm_html(pc, npc, castle, Castle::FUNC_TELEPORT, level)
    when "BF"
      level = st.shift.to_i
      htmltext = func_confirm_html(pc, npc, castle, Castle::FUNC_SUPPORT, level)
    when "set_func"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_SET_FUNCTIONS)
        func = st.shift.to_i
        level = st.shift.to_i
        if level == 0
          castle.update_functions(pc, func, level, 0, 0, false)
        elsif !castle.update_functions(pc, func, level, get_function_fee(func, level), get_function_ratio(func), castle.get_function(func).nil?)
          htmltext = "chamberlain-09.html"
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "functions"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_USE_FUNCTIONS)
        hp = castle.get_function(Castle::FUNC_RESTORE_HP)
        mp = castle.get_function(Castle::FUNC_RESTORE_MP)
        xp = castle.get_function(Castle::FUNC_RESTORE_EXP)
        html = get_html_packet(pc, npc, "castledecofunction.html")
        html["%HPDepth%"] = hp ? hp.lvl : "0"
        html["%MPDepth%"] = mp ? mp.lvl : "0"
        html["%XPDepth%"] = xp ? xp.lvl : "0"
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "teleport"
      if !owner?(pc, npc) || !pc.has_clan_privilege?(ClanPrivilege::CS_USE_FUNCTIONS)
        htmltext = "chamberlain-21.html"
      elsif (fn = castle.get_function(Castle::FUNC_TELEPORT)).nil?
        htmltext = "castlefuncdisabled.html"
      else
        htmltext = "#{npc.id}-t#{fn.lvl}.html"
      end
    when "goto"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_USE_FUNCTIONS)
        loc_id = st.shift.to_i
        if list = TeleportLocationTable[loc_id]?
          if take_items(pc, list.item_id, list.price)
            pc.tele_to_location(list.x, list.y, list.z)
          end
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "buffer"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_USE_FUNCTIONS)
        if (fn = castle.get_function(Castle::FUNC_SUPPORT)).nil?
          htmltext = "castlefuncdisabled.html"
        else
          html = get_html_packet(pc, npc, "castlebuff-0#{fn.lvl}.html")
          html["%MPLeft%"] = npc.current_mp.to_i
          pc.send_packet(html)
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "cast_buff"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_USE_FUNCTIONS)
        if castle.get_function(Castle::FUNC_SUPPORT).nil?
          htmltext = "castlefuncdisabled.html"
        else
          index = st.shift.to_i
          if BUFFS.size > index
            holder = BUFFS[index]
            if holder.skill.mp_consume2 < npc.current_mp
              npc.target = pc
              npc.do_cast(holder)
              html = get_html_packet(pc, npc, "castleafterbuff.html")
            else
              html = get_html_packet(pc, npc, "castlenotenoughmp.html")
            end

            html["%MPLeft%"] = npc.current_mp.to_i
            pc.send_packet(html)
          end
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "list_siege_clans"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_MANAGE_SIEGE)
        castle.siege.list_register_clan(pc)
      else
        htmltext = "chamberlain-21.html"
      end
    when "list_territory_clans"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_MANAGE_SIEGE)
        pc.send_packet(ExShowDominionRegistry.new(castle.residence_id, pc))
      else
        htmltext = "chamberlain-21.html"
      end
    when "manor"
      if Config.allow_manor
        if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_MANOR_ADMIN)
          htmltext =  "manor.html"
        else
          htmltext = "chamberlain-21.html"
        end
      else
        pc.send_message("Manor system is deactivated.")
      end
    when "products"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_USE_FUNCTIONS)
        html = get_html_packet(pc, npc, "chamberlain-22.html")
        html["%npcId%"] = npc.id
        pc.send_packet(html)
      else
        htmltext = "chamberlain-21.html"
      end
    when "buy"
      if owner?(pc, npc) && pc.has_clan_privilege?(ClanPrivilege::CS_USE_FUNCTIONS)
        unless npc.is_a?(L2MerchantInstance)
          raise "Expected #{npc} to be a L2MerchantInstance"
        end
        npc.show_buy_window(pc, st.shift.to_i)
      else
        htmltext = "chamberlain-21.html"
      end
    when "give_crown"
      if castle.siege.in_progress?
        htmltext = "chamberlain-08.html"
      elsif npc.my_lord?(pc)
        if has_quest_items?(pc, CROWN)
          htmltext = "chamberlain-24.html"
        else
          html = get_html_packet(pc, npc, "chamberlain-25.html")
          html["%owner_name%"] = pc.name
          html["%feud_name%"] = 1001000 + castle.residence_id
          pc.send_packet(html)
          give_items(pc, CROWN, 1)
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "manors_cert"
      if npc.my_lord?(pc)
        if castle.siege.in_progress?
          htmltext = "chamberlain-08.html"
        else
          if SevenSigns.get_player_cabal(pc.l2id) == SevenSigns::CABAL_DAWN && SevenSigns.competition_period?
            ticket_count = castle.ticket_buy_count
            if ticket_count < Config.ssq_dawn_ticket_quantity / Config.ssq_dawn_ticket_bundle
              html = get_html_packet(pc, npc, "ssq_selldawnticket.html")
              html["%DawnTicketLeft%"] = Config.ssq_dawn_ticket_quantity - (ticket_count * Config.ssq_dawn_ticket_bundle)
              html["%DawnTicketBundle%"] = Config.ssq_dawn_ticket_bundle
              html["%DawnTicketPrice%"] = Config.ssq_dawn_ticket_price * Config.ssq_dawn_ticket_bundle
              pc.send_packet(html)
            else
              htmltext = "ssq_notenoughticket.html"
            end
          else
            htmltext = "ssq_notdawnorevent.html"
          end
        end
      else
        htmltext = "chamberlain-21.html"
      end
    when "manors_cert_confirm"
      if npc.my_lord?(pc)
        if castle.siege.in_progress?
          htmltext = "chamberlain-08.html"
        else
          if SevenSigns.get_player_cabal(pc.l2id) == SevenSigns::CABAL_DAWN && SevenSigns.competition_period?
            ticket_count = castle.ticket_buy_count
            if ticket_count < Config.ssq_dawn_ticket_quantity / Config.ssq_dawn_ticket_bundle
              total_cost = Config.ssq_dawn_ticket_price * Config.ssq_dawn_ticket_bundle
              if pc.adena >= total_cost
                take_items(pc, Inventory::ADENA_ID, total_cost)
                give_items(pc, Config.ssq_manors_agreement_id, Config.ssq_dawn_ticket_bundle)
                castle.ticket_buy_count = ticket_count + 1
              else
                htmltext = "chamberlain-09.html"
              end
            else
              htmltext = "ssq_notenoughticket.html"
            end
          else
            htmltext = "ssq_notdawnorevent.html"
          end
        end
      else
        htmltext = "chamberlain-21.html"
      end
    else
      # [automatically added else]
    end


    htmltext
  end

  def on_first_talk(npc, pc)
    owner?(pc, npc) ? "chamberlain-01.html" : "chamberlain-04.html"
  end

  @[Register(event: ON_NPC_MANOR_BYPASS, register: NPC, id: {35100, 35142, 35184, 35226, 35274,  35316, 35363, 35509, 35555})]
  def on_npc_manor_bypass(evt : OnNpcManorBypass)
    pc = evt.active_char
    npc = evt.target

    if owner?(pc, npc)
      if CastleManorManager.under_maintenance?
        pc.send_packet(SystemMessageId::THE_MANOR_SYSTEM_IS_CURRENTLY_UNDER_MAINTENANCE)
        return
      end

      castle_id = evt.manor_id == -1 ? npc.castle.residence_id : evt.manor_id
      case evt.request
      when 3 # Seed info
        pc.send_packet(ExShowSeedInfo.new(castle_id, evt.next_period?, true))
      when 4 # Crop info
        pc.send_packet(ExShowCropInfo.new(castle_id, evt.next_period?, true))
      when 5 # Basic info
        pc.send_packet(ExShowManorDefaultInfo.new(true))
      when 7 # Seed settings
        if CastleManorManager.manor_approved?
          pc.send_packet(SystemMessageId::A_MANOR_CANNOT_BE_SET_UP_BETWEEN_4_30_AM_AND_8_PM)
          return
        end
        pc.send_packet(ExShowSeedSetting.new(castle_id))
      when 8 # Crop settings
        if CastleManorManager.manor_approved?
          pc.send_packet(SystemMessageId::A_MANOR_CANNOT_BE_SET_UP_BETWEEN_4_30_AM_AND_8_PM)
          return
        end
        pc.send_packet(ExShowCropSetting.new(castle_id))
      else
        warn { "pc #{pc.name} (#{pc.l2id}) sent unknown request id #{evt.request}." }
      end
    end
  end
end
