class Packets::Incoming::EnterWorld < GameClientPacket
  no_action_request

  MIN_HP = 0.5
  COMBAT_FLAG = 9819

  @tracert = Slice(Slice(UInt8)).empty

  private def read_impl
    buffer.pos += 84
    @tracert = Slice.new(5) { b 4 }
  end

  private def run_impl
    return unless pc = active_char
    # LoginServerThread.send_client_tracert(pc.account_name, address)
    # client.tracert = @tracert

    if Config.restore_player_instance
      pc.instance_id = InstanceManager.get_player_instance(pc.l2id)
    else
      id = InstanceManager.get_player_instance(pc.l2id)
      if id > 0
        InstanceManager.get_instance(id).not_nil!.remove_player(pc.l2id)
      end
    end

    if Config.debug
      if L2World.find_object(pc.l2id)
        warn { "#{pc} already exists in L2World." }
      end
    end

    client.state = GameClient::State::IN_GAME

    if pc.gm?
      if Config.gm_startup_invulnerable
        if AdminData.has_access?("admin_invul", pc.access_level)
          pc.invul = true
        end
      end

      if Config.gm_startup_invisible
        if AdminData.has_access?("admin_invisible", pc.access_level)
          pc.invisible = true
        end
      end

      if Config.gm_startup_silence
        if AdminData.has_access?("admin_silence", pc.access_level)
          pc.silence_mode = true
        end
      end

      if Config.gm_startup_diet_mode
        if AdminData.has_access?("admin_diet", pc.access_level)
          pc.diet_mode = true
        end
        pc.refresh_overloaded
      end

      if Config.gm_startup_auto_list && AdminData.has_access?("admin_gmliston", pc.access_level)
        AdminData.add_gm(pc, false)
      else
        AdminData.add_gm(pc, true)
      end

      if Config.gm_give_special_skills
        SkillTreesData.add_skills(pc, false)
      end

      if Config.gm_give_special_aura_skills
        SkillTreesData.add_skills(pc, true)
      end
    end

    if pc.current_hp < MIN_HP
      pc.dead = true
    end

    if clan = pc.clan
      pc.send_packet(PledgeSkillList.new(clan))
      notify_clan_members(pc)
      notify_sponsor_or_apprentice(pc)
      if hall = ClanHallManager.get_clan_hall_by_owner(clan)
        unless hall.paid?
          pc.send_packet(SystemMessageId::PAYMENT_FOR_YOUR_CLAN_HALL_HAS_NOT_BEEN_MADE_PLEASE_MAKE_PAYMENT_TO_YOUR_CLAN_WAREHOUSE_BY_S1_TOMORROW)
        end
      end

      SiegeManager.sieges.each do |siege|
        unless siege.in_progress?
          next
        end

        if siege.attacker?(clan)
          pc.siege_state = 1
          pc.siege_side = siege.castle.residence_id
        elsif siege.defender?(clan)
          pc.siege_state = 2
          pc.siege_side = siege.castle.residence_id
        end
      end


      FortSiegeManager.sieges.each do |siege|
        unless siege.in_progress?
          next
        end

        if siege.attacker?(clan)
          pc.siege_state = 1
          pc.siege_side = siege.fort.residence_id
        elsif siege.defender?(clan)
          pc.siege_state = 2
          pc.siege_side = siege.fort.residence_id
        end
      end

      ClanHallSiegeManager.conquerable_halls.each_value do |hall|
        unless hall.in_siege?
          next
        end

        if hall.registered?(clan)
          pc.siege_state = 1
          pc.siege_side = hall.id
          pc.in_hideout_siege = true
        end
      end

      send_packet(PledgeShowMemberListAll.new(clan, pc))
      send_packet(PledgeStatusChanged.new(clan))

      if clan.castle_id > 0
        CastleManager.get_castle_by_owner(clan).not_nil!.give_residential_skills(pc)
      end

      if clan.fort_id > 0
        FortManager.get_fort_by_owner(clan).not_nil!.give_residential_skills(pc)
      end

      show_clan_notice = clan.notice_enabled?
    end

    if TerritoryWarManager.get_registered_territory_id(pc) > 0
      if TerritoryWarManager.tw_in_progress?
        pc.siege_state = 1
      end

      pc.siege_side = TerritoryWarManager.get_registered_territory_id(pc)
    end

    if SevenSigns.instance.seal_validation_period? && SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE) != SevenSigns::CABAL_NULL
      cabal = SevenSigns.instance.get_player_cabal(pc.l2id)
      if cabal != SevenSigns::CABAL_NULL
        if cabal == SevenSigns.instance.get_seal_owner(SevenSigns::SEAL_STRIFE)
          pc.add_skill(CommonSkill::THE_VICTOR_OF_WAR.skill)
        else
          pc.add_skill(CommonSkill::THE_VANQUISHED_OF_WAR.skill)
        end
      end
    else
      pc.remove_skill(CommonSkill::THE_VICTOR_OF_WAR.skill)
      pc.remove_skill(CommonSkill::THE_VICTOR_OF_WAR.skill)
    end

    if Config.enable_vitality && Config.recover_vitality_on_reconnect
      points = (Config.rate_recovery_on_reconnect * (Time.ms - pc.last_access)).fdiv(60000)
      if points > 0
        pc.update_vitality_points(points, false, true)
      end
    end

    pc.check_reco_bonus_task
    pc.broadcast_user_info
    pc.macros.send_update
    send_packet(ItemList.new(pc, false))
    pc.query_game_guard
    pc.send_packet(ExGetBookMarkInfoPacket.new(pc))
    pc.send_packet(ShortcutInit.new(pc))
    pc.send_packet(ExBasicActionList::DEFAULT_LIST)
    pc.send_skill_list
    pc.recalc_henna_stats
    pc.send_packet(HennaInfo.new(pc))
    Quest.player_enter(pc)
    pc.send_packet(QuestList.new)
    if Config.player_spawn_protection > 0
      pc.protection = true
    end
    pc.spawn_me(*pc.xyz)
    pc.inventory.apply_item_skills
    if L2Event.participant?(pc)
      L2Event.restore_player_event_status(pc)
    end
    if Config.allow_wedding
      engage(pc)
      notify_partner(pc, pc.partner_id)
    end

    if pc.cursed_weapon_equipped?
      info { "#{pc.name} has a cursed weapon." }
      CursedWeaponsManager.get_cursed_weapon(pc.cursed_weapon_equipped_id)
      .not_nil!.cursed_on_login
    end

    pc.update_effect_icons
    pc.send_packet(EtcStatusUpdate.new(pc))
    pc.send_packet(ExStorageMaxCount.new(pc))
    send_packet(FriendList.new(pc))
    if pc.has_friends?
      sm = SystemMessage.friend_s1_has_logged_in
      sm.add_char_name(pc)
      pc.friends.each do |id|
        if friend = L2World.find_object(id)
          friend.send_packet(sm)
        end
      end
    end

    pc.send_packet(SystemMessageId::WELCOME_TO_LINEAGE)

    # pc.send_message(get_text("VGhpcyBzZXJ2ZXIgdXNlcyBMMkosIGEgcHJvamVjdCBmb3VuZGVkIGJ5IEwyQ2hlZg=="))
    # pc.send_message(get_text("YW5kIGRldmVsb3BlZCBieSBMMkogVGVhbSBhdCB3d3cubDJqc2VydmVyLmNvbQ=="))
    # pc.send_message(get_text("Q29weXJpZ2h0IDIwMDQtMjAxOQ=="))
    # pc.send_message(get_text("VGhhbmsgeW91IGZvciAxNSB5ZWFycyE="))

    SevenSigns.instance.send_current_period_msg(pc)
    AnnouncementsTable.show_announcements(pc)

    if clan && show_clan_notice
      notice = NpcHtmlMessage.new
      notice.set_file(pc, "data/html/clanNotice.htm")
      notice["%clan_name%"] = clan.name
      notice["%notice_text%"] = clan.notice
      notice.disable_validation
      send_packet(notice)
    elsif Config.server_news
      html = HtmCache.get_htm("data/html/servnews.htm") || "servnews.htm not found."
      send_packet(NpcHtmlMessage.new(html))
    end

    if Config.petitioning_allowed
      PetitionManager.check_petition_messages(pc)
    end

    if pc.looks_dead?
      send_packet(Die.new(pc))
    end

    pc.on_player_enter

    send_packet(SkillCoolTime.new(pc))
    send_packet(ExVoteSystemInfo.new(pc))
    send_packet(ExNevitAdventPointInfoPacket.new(0))
    send_packet(ExNevitAdventTimeChange.new(-1))
    send_packet(ExShowContactList.new(pc))

    pc.inventory.items.each do |item|
      if item.time_limited_item?
        item.schedule_life_time_task
      end
      if item.shadow_item? && item.equipped?
        item.decrease_mana(false)
      end
    end

    pc.warehouse.items.each do |item|
      if item.time_limited_item?
        item.schedule_life_time_task
      end
    end

    if DimensionalRiftManager.in_rift_zone?(*pc.xyz, false)
      DimensionalRiftManager.teleport_to_waiting_room(pc)
    end

    if pc.clan_join_expiry_time > Time.ms
      pc.send_packet(SystemMessageId::CLAN_MEMBERSHIP_TERMINATED)
    end

    if flag = pc.inventory.get_item_by_item_id(COMBAT_FLAG)
      if fort = FortManager.get_fort(pc)
        FortSiegeManager.drop_combat_flag(pc, fort.residence_id)
      else
        slot = pc.inventory.get_slot_from_item(flag)
        pc.inventory.unequip_item_in_body_slot(slot)
        pc.destroy_item("CombatFlag", flag, nil, true)
      end
    end

    if !pc.override_zone_conditions? && pc.inside_siege_zone?
      if !pc.in_siege? || pc.siege_state < 2
        pc.tele_to_location(TeleportWhereType::TOWN)
      end
    end

    if Config.allow_mail
      if MailManager.has_unread_post?(pc)
        send_packet(ExNoticePostArrived::FALSE)
      end
    end

    # TvTEvent.on_login(pc)

    if Config.welcome_message_enabled
      text = Config.welcome_message_text
      time = Config.welcome_message_time
      msg  = ExShowScreenMessage.new(text, time)
      pc.send_packet(msg)
    end

    birthday = pc.check_birthday
    if birthday == 0
      pc.send_packet(SystemMessageId::YOUR_BIRTHDAY_GIFT_HAS_ARRIVED)
    elsif birthday != -1
      sm = SystemMessage.there_are_s1_days_until_your_characters_birthday
      sm.add_int(birthday)
      pc.send_packet(sm)
    end

    unless pc.premium_item_list.empty?
      pc.send_packet(ExNotifyPremiumItem::STATIC_PACKET)
    end

    if pc.race.dark_elf?
      if pc.get_skill_level(294) == 1 && (skill = SkillData[294, 1]?)
        if GameTimer.night?
          sm = SystemMessage.it_is_now_midnight_and_the_effect_of_s1_can_be_felt
          sm.add_skill_name(skill)
        else
          sm = SystemMessage.it_is_dawn_and_the_effect_of_s1_will_now_disappear
          sm.add_skill_name(skill)
        end
        pc.send_packet(sm)
        pc.update_and_broadcast_status(2)
      end
    end

    pc.refresh_overloaded
    if tmp = pc.original_cp_hp_mp
      pc.current_cp, pc.current_hp, pc.current_mp = tmp
      pc.original_cp_hp_mp = nil
    end

    # Unstuck players that had client open when server crashed.
    action_failed
  end

  private def notify_clan_members(pc)
    if clan = pc.clan
      clan.get_clan_member(pc.l2id).not_nil!.player_instance = pc
      sm = SystemMessage.clan_member_s1_logged_in
      sm.add_string(pc.name)
      clan.broadcast_to_other_online_members(sm, pc)
      packet = PledgeShowMemberListUpdate.new(pc)
      clan.broadcast_to_other_online_members(packet, pc)
    end
  end

  private def notify_sponsor_or_apprentice(pc)
    if pc.sponsor != 0
      if sponsor = L2World.get_player(pc.sponsor)
        sm = SystemMessage.your_apprentice_s1_has_logged_in
        sm.add_string(pc.name)
        sponsor.send_packet(sm)
      end
    elsif pc.apprentice != 0
      if apprentice = L2World.get_player(pc.apprentice)
        sm = SystemMessage.your_sponsor_c1_has_logged_in
        sm.add_string(pc.name)
        apprentice.send_packet(sm)
      end
    end
  end

  private def engage(pc)
    CoupleManager.couples.each do |couple|
      if couple.player1_id == pc.l2id || couple.player2_id == pc.l2id
        if couple.married?
          pc.married = true
        end

        pc.couple_id = couple.id

        if couple.player1_id == pc.l2id
          pc.partner_id = couple.player2_id
        else
          pc.partner_id = couple.player1_id
        end
      end
    end
  end

  private def notify_partner(pc, partner_id)
    if partner = L2World.get_player(partner_id)
      partner.send_message("Your partner has logged in.")
    end
  end

  private def get_text(str)
    String.new(Base64.decode(str))
  end
end
