class Scripts::Q00171_ActsOfEvil < Quest
  # NPCs
  private TRADER_ARODIN = 30207
  private GUARD_ALVAH = 30381
  private TYRA = 30420
  private NETI = 30425
  private TRADER_ROLENTO = 30437
  private TUREK_CHIEF_BURAI = 30617
  # Items
  private BLADE_MOLD = 4239
  private TYRAS_BILL = 4240
  private RANGERS_REPORT1 = 4241
  private RANGERS_REPORT2 = 4242
  private RANGERS_REPORT3 = 4243
  private RANGERS_REPORT4 = 4244
  private WEAPONS_TRADE_CONTRACT = 4245
  private ATTACK_DIRECTIVES = 4246
  private CERTIFICATE_OF_THE_SILVER_GUILD = 4247
  private ROLENTOS_CARGOBOX = 4248
  private OL_MAHUM_CAPTAINS_HEAD = 4249
  # Monster
  private TUMRAN_BUGBEAR = 20062
  private TUMRAN_BUGBEAR_WARRIOR = 20064
  private OL_MAHUM_CAPTAIN = 20066
  private OL_MAHUM_GENERAL = 20438
  private TUREK_ORC_ARCHER = 20496
  private TUREK_ORC_SKIRMISHER = 20497
  private TUREK_ORC_SUPPLIER = 20498
  private TUREK_ORC_FOOTMAN = 20499
  # Quest Monster
  private OL_MAHUM_SUPPORT_TROOP = 27190
  # Misc
  private MIN_LEVEL = 27

  def initialize
    super(171, self.class.simple_name, "Acts Of Evil")

    add_start_npc(GUARD_ALVAH)
    add_talk_id(
      GUARD_ALVAH, TRADER_ARODIN, TYRA, NETI, TRADER_ROLENTO, TUREK_CHIEF_BURAI
    )
    add_kill_id(
      TUMRAN_BUGBEAR, TUMRAN_BUGBEAR_WARRIOR, OL_MAHUM_CAPTAIN,
      OL_MAHUM_GENERAL, TUREK_ORC_ARCHER, TUREK_ORC_SKIRMISHER,
      TUREK_ORC_SUPPLIER, TUREK_ORC_FOOTMAN, OL_MAHUM_SUPPORT_TROOP
    )
    add_spawn_id(OL_MAHUM_SUPPORT_TROOP)
    register_quest_items(
      BLADE_MOLD, TYRAS_BILL, RANGERS_REPORT1, RANGERS_REPORT2, RANGERS_REPORT3,
      RANGERS_REPORT4, WEAPONS_TRADE_CONTRACT, ATTACK_DIRECTIVES,
      CERTIFICATE_OF_THE_SILVER_GUILD, ROLENTOS_CARGOBOX, OL_MAHUM_CAPTAINS_HEAD
    )
  end

  def on_adv_event(event, npc, pc)
    if event == "DESPAWN"
      if npc
        npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::YOU_SHOULD_CONSIDER_GOING_BACK))
        npc.delete_me
      end

      return super
    end

    return unless pc && (qs = get_quest_state(pc, false))

    html = nil
    case event
    when "30381-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "30381-07.html"
      qs.memo_state = 5
      qs.set_cond(5, true)
      html = event
    when "30381-12.html"
      qs.memo_state = 7
      qs.set_cond(7, true)
      html = event
    when "30437-04.html"
      take_items(pc, WEAPONS_TRADE_CONTRACT, 1)
      give_items(pc, CERTIFICATE_OF_THE_SILVER_GUILD, 1)
      give_items(pc, ROLENTOS_CARGOBOX, 1)
      qs.memo_state = 9
      qs.set_cond(9, true)
      html = event
    when "30207-01a.html", "30437-02.html", "30437-03.html", "30617-03.html",
         "30617-04.html"
      html = event
    when "30617-05.html"
      take_items(pc, ATTACK_DIRECTIVES, 1)
      take_items(pc, CERTIFICATE_OF_THE_SILVER_GUILD, 1)
      take_items(pc, ROLENTOS_CARGOBOX, 1)
      qs.memo_state = 10
      qs.set_cond(10, true)
      html = event
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when TUMRAN_BUGBEAR, TUMRAN_BUGBEAR_WARRIOR
        if qs.memo_state?(5)
          if !has_quest_items?(killer, RANGERS_REPORT1)
            give_items(killer, RANGERS_REPORT1, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          elsif has_quest_items?(killer, RANGERS_REPORT1) && !has_quest_items?(killer, RANGERS_REPORT2)
            if Rnd.rand(100) <= 19
              give_items(killer, RANGERS_REPORT2, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          elsif has_quest_items?(killer, RANGERS_REPORT1, RANGERS_REPORT2) && !has_quest_items?(killer, RANGERS_REPORT3)
            if Rnd.rand(100) <= 19
              give_items(killer, RANGERS_REPORT3, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          elsif has_quest_items?(killer, RANGERS_REPORT1, RANGERS_REPORT2, RANGERS_REPORT3) && !has_quest_items?(killer, RANGERS_REPORT4)
            if Rnd.rand(100) <= 19
              give_items(killer, RANGERS_REPORT4, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when OL_MAHUM_CAPTAIN
        if qs.memo_state?(10) && get_quest_items_count(killer, OL_MAHUM_CAPTAINS_HEAD) < 30
          if Rnd.rand(100) <= 49
            give_items(killer, OL_MAHUM_CAPTAINS_HEAD, 1)
            if get_quest_items_count(killer, OL_MAHUM_CAPTAINS_HEAD) == 30
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when OL_MAHUM_GENERAL
        if qs.memo_state?(6)
          if Rnd.rand(100) <= 9
            unless has_quest_items?(killer, WEAPONS_TRADE_CONTRACT)
              give_items(killer, WEAPONS_TRADE_CONTRACT, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
            unless has_quest_items?(killer, ATTACK_DIRECTIVES)
              give_items(killer, ATTACK_DIRECTIVES, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when TUREK_ORC_ARCHER
        if qs.memo_state?(2) && get_quest_items_count(killer, BLADE_MOLD) < 20
          if Rnd.rand(100) < 53
            give_items(killer, BLADE_MOLD, 1)
            if get_quest_items_count(killer, BLADE_MOLD) == 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
          if get_quest_items_count(killer, BLADE_MOLD) == 5
            add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
          end
          if get_quest_items_count(killer, BLADE_MOLD) >= 10
            if Rnd.rand(100) <= 24
              add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
            end
          end
        end
      when TUREK_ORC_SKIRMISHER
        if qs.memo_state?(2) && get_quest_items_count(killer, BLADE_MOLD) < 20
          if Rnd.rand(100) < 55
            give_items(killer, BLADE_MOLD, 1)
            if get_quest_items_count(killer, BLADE_MOLD) == 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
          if get_quest_items_count(killer, BLADE_MOLD) == 5
            add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
          end
          if get_quest_items_count(killer, BLADE_MOLD) >= 10
            if Rnd.rand(100) <= 24
              add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
            end
          end
        end
      when TUREK_ORC_SUPPLIER
        if qs.memo_state?(2) && get_quest_items_count(killer, BLADE_MOLD) < 20
          if Rnd.rand(100) < 51
            give_items(killer, BLADE_MOLD, 1)
            if get_quest_items_count(killer, BLADE_MOLD) == 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
          if get_quest_items_count(killer, BLADE_MOLD) == 5
            add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
          end
          if get_quest_items_count(killer, BLADE_MOLD) >= 10
            if Rnd.rand(100) <= 24
              add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
            end
          end
        end
      when TUREK_ORC_FOOTMAN
        if qs.memo_state?(2) && get_quest_items_count(killer, BLADE_MOLD) < 20
          if Rnd.rand(2) < 1
            give_items(killer, BLADE_MOLD, 1)
            if get_quest_items_count(killer, BLADE_MOLD) == 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
          if get_quest_items_count(killer, BLADE_MOLD) == 5
            add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
          end
          if get_quest_items_count(killer, BLADE_MOLD) >= 10
            if Rnd.rand(100) <= 24
              add_attack_desire(add_spawn(OL_MAHUM_SUPPORT_TROOP, npc, true, 0, false), killer)
            end
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    memo_state = qs.memo_state

    if qs.created?
      if npc.id == GUARD_ALVAH
        if pc.level < MIN_LEVEL
          html = "30381-01.htm"
        else
          html = "30381-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when GUARD_ALVAH
        case qs.cond
        when 1
          html = "30381-04.html"
        when 2, 3
          html = "30381-05.html"
        when 4
          html = "30381-06.html"
        when 5
          if has_quest_items?(pc, RANGERS_REPORT1, RANGERS_REPORT2, RANGERS_REPORT3, RANGERS_REPORT4)
            take_items(pc, RANGERS_REPORT1, 1)
            take_items(pc, RANGERS_REPORT2, 1)
            take_items(pc, RANGERS_REPORT3, 1)
            take_items(pc, RANGERS_REPORT4, 1)
            qs.memo_state = 6
            qs.set_cond(6, true)
            html = "30381-09.html"
          else
            html = "30381-08.html"
          end
        when 6
          if has_quest_items?(pc, WEAPONS_TRADE_CONTRACT, ATTACK_DIRECTIVES)
            html = "30381-11.html"
          else
            html = "30381-10.html"
          end
        when 7
          html = "30381-13.html"
        when 8
          html = "30381-14.html"
        when 9
          html = "30381-15.html"
        when 10
          html = "30381-16.html"
        when 11
          give_adena(pc, 95_000, true)
          add_exp_and_sp(pc, 159_820, 9182)
          html = "30381-17.html"
          qs.exit_quest(false, true)
        end
      when TRADER_ARODIN
        if memo_state == 1
          qs.memo_state = 2
          qs.set_cond(2, true)
          html = "30207-01.html"
        elsif memo_state == 2
          if get_quest_items_count(pc, BLADE_MOLD) < 20
            html = "30207-02.html"
          else
            html = "30207-03.html"
          end
        elsif memo_state == 3
          take_items(pc, TYRAS_BILL, 1)
          qs.memo_state = 4
          qs.set_cond(4, true)
          html = "30207-04.html"
        elsif memo_state >= 4
          html = "30207-05.html"
        end
      when TYRA
        if memo_state == 2
          if get_quest_items_count(pc, BLADE_MOLD) < 20
            html = "30420-01.html"
          else
            take_items(pc, BLADE_MOLD, -1)
            give_items(pc, TYRAS_BILL, 1)
            qs.memo_state = 3
            qs.set_cond(3, true)
            html = "30420-02.html"
          end
        elsif memo_state == 3
          html = "30420-03.html"
        elsif memo_state >= 4
          html = "30420-04.html"
        end
      when NETI
        if memo_state == 7
          qs.memo_state = 8
          qs.set_cond(8, true)
          html = "30425-01.html"
        elsif memo_state == 8
          html = "30425-02.html"
        elsif memo_state >= 9
          html = "30425-03.html"
        end
      when TRADER_ROLENTO
        if memo_state == 8
          html = "30437-02.html"
        elsif memo_state == 9
          html = "30437-05.html"
        elsif memo_state >= 10
          html = "30437-06.html"
        end
      when TUREK_CHIEF_BURAI
        if memo_state < 9
          html = "30617-01.html"
        elsif memo_state == 9
          html = "30617-02.html"
        elsif memo_state == 10
          if get_quest_items_count(pc, OL_MAHUM_CAPTAINS_HEAD) < 30
            html = "30617-06.html"
          else
            give_adena(pc, 8000, true)
            take_items(pc, OL_MAHUM_CAPTAINS_HEAD, -1)
            qs.memo_state = 11
            qs.set_cond(11, true)
            html = "30617-07.html"
          end
        elsif memo_state == 11
          html = "30617-08.html"
        end
      end
    elsif qs.completed?
      if npc.id == GUARD_ALVAH
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_spawn(npc)
    start_quest_timer("DESPAWN", 200_000, npc, nil)
    super
  end
end
