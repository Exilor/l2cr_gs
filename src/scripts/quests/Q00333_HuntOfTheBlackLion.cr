class Scripts::Q00333_HuntOfTheBlackLion < Quest
  # NPCs
  private ABYSSAL_CELEBRANT_UNDRIAS = 30130
  private BLACKSMITH_RUPIO = 30471
  private IRON_GATES_LOCKIRIN = 30531
  private MERCENARY_CAPTAIN_SOPHYA = 30735
  private MERCENARY_REEDFOOT = 30736
  private GUILDSMAN_MORGON = 30737
  # Items
  private BLACK_LION_MARK = 1369
  private CARGO_BOX_1ST = 3440
  private CARGO_BOX_2ND = 3441
  private CARGO_BOX_3RD = 3442
  private CARGO_BOX_4TH = 3443
  private STATUE_OF_SHILEN_HEAD = 3457
  private STATUE_OF_SHILEN_TORSO = 3458
  private STATUE_OF_SHILEN_ARM = 3459
  private STATUE_OF_SHILEN_LEG = 3460
  private COMPLETE_STATUE_OF_SHILEN = 3461
  private FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE = 3462
  private FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE = 3463
  private FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE = 3464
  private FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE = 3465
  private COMPLETE_ANCIENT_TABLET = 3466
  private SOPHYAS_1ST_ORDER = 3671
  private SOPHYAS_2ND_ORDER = 3672
  private SOPHYAS_3RD_ORDER = 3673
  private SOPHYAS_4TH_ORDER = 3674
  private LIONS_CLAW = 3675
  private LIONS_EYE = 3676
  private GUILD_COIN = 3677
  private UNDEAD_ASH = 3848
  private BLOODY_AXE_INSIGNIA = 3849
  private DELU_LIZARDMAN_FANG = 3850
  private STAKATO_TALON = 3851
  # Rewards
  private ALACRITY_POTION = 735
  private SCROLL_OF_ESCAPE = 736
  private HEALING_POTION = 1061
  private SOULSHOT_D_GRADE = 1463
  private SPIRITSHOT_D_GRADE = 2510
  private GLUDIO_APPLES = 3444
  private DION_CORN_MEAL = 3445
  private DIRE_WOLF_PELTS = 3446
  private MOONSTONE = 3447
  private GLUDIO_WHEAT_FLOUR = 3448
  private SPIDERSILK_ROPE = 3449
  private ALEXANDRITE = 3450
  private SILVER_TEA_SERVICE = 3451
  private MECHANIC_GOLEM_SPACE_PARTS = 3452
  private FIRE_EMERALD = 3453
  private AVELLAN_SILK_FROCK = 3454
  private FERIOTIC_PORCELAIN_URM = 3455
  private IMPERIAL_DIAMOND = 3456
  # Monster
  private MARSH_STAKATO = 20157
  private NEER_CRAWLER = 20160
  private SPECTER = 20171
  private SORROW_MAIDEN = 20197
  private NEER_CRAWLER_BERSERKER = 20198
  private STRAIN = 20200
  private GHOUL = 20201
  private OL_MAHUM_GUERILLA = 20207
  private OL_MAHUM_RAIDER = 20208
  private OL_MAHUM_MARKSMAN = 20209
  private OL_MAHUM_SERGEANT = 20210
  private OL_MAHUM_CAPTAIN = 20211
  private MARSH_STAKATO_WORKER = 20230
  private MARSH_STAKATO_SOLDIER = 20232
  private MARSH_STAKATO_DRONE = 20234
  private DELU_LIZARDMAN = 20251
  private DELU_LIZARDMAN_SCOUT = 20252
  private DELU_LIZARDMAN_WARRIOR = 20253
  # Quest Monster
  private DELU_LIZARDMAN_HEADHUNTER = 27151
  private MARSH_STAKATO_MARQUESS = 27152
  # Misc
  private MIN_LEVEL = 25

  def initialize
    super(333, self.class.simple_name, "Hunt Of The Black Lion")

    add_start_npc(MERCENARY_CAPTAIN_SOPHYA)
    add_talk_id(
      MERCENARY_CAPTAIN_SOPHYA, ABYSSAL_CELEBRANT_UNDRIAS, BLACKSMITH_RUPIO,
      IRON_GATES_LOCKIRIN, MERCENARY_REEDFOOT, GUILDSMAN_MORGON
    )
    add_kill_id(
      MARSH_STAKATO, NEER_CRAWLER, SPECTER, SORROW_MAIDEN,
      NEER_CRAWLER_BERSERKER, STRAIN, GHOUL, OL_MAHUM_GUERILLA, OL_MAHUM_RAIDER,
      OL_MAHUM_MARKSMAN, OL_MAHUM_SERGEANT, OL_MAHUM_CAPTAIN,
      MARSH_STAKATO_WORKER, MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE,
      DELU_LIZARDMAN, DELU_LIZARDMAN_SCOUT, DELU_LIZARDMAN_WARRIOR,
      DELU_LIZARDMAN_HEADHUNTER, MARSH_STAKATO_MARQUESS
    )
    register_quest_items(
      BLACK_LION_MARK, CARGO_BOX_1ST, CARGO_BOX_2ND, CARGO_BOX_3RD,
      CARGO_BOX_4TH, STATUE_OF_SHILEN_HEAD, STATUE_OF_SHILEN_TORSO,
      STATUE_OF_SHILEN_ARM, STATUE_OF_SHILEN_LEG, COMPLETE_STATUE_OF_SHILEN,
      FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE,
      FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE,
      FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE,
      FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE, COMPLETE_ANCIENT_TABLET,
      SOPHYAS_1ST_ORDER, SOPHYAS_2ND_ORDER, SOPHYAS_3RD_ORDER,
      SOPHYAS_4TH_ORDER, LIONS_CLAW, LIONS_EYE, GUILD_COIN, UNDEAD_ASH,
      BLOODY_AXE_INSIGNIA, DELU_LIZARDMAN_FANG, STAKATO_TALON
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end
    chance = Rnd.rand(100)
    chance1 = Rnd.rand(100)

    case event
    when "30735-04.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30735-05.html", "30735-06.html", "30735-07.html", "30735-08.html",
         "30735-09.html", "30130-05.html", "30531-05.html", "30735-21.html",
         "30735-24a.html", "30735-25b.html", "30736-06.html", "30736-09.html",
         "30737-07.html"
      html = event
    when "30735-10.html"
      unless has_quest_items?(pc, SOPHYAS_1ST_ORDER)
        give_items(pc, SOPHYAS_1ST_ORDER, 1)
        html = event
      end
    when "30735-11.html"
      unless has_quest_items?(pc, SOPHYAS_2ND_ORDER)
        give_items(pc, SOPHYAS_2ND_ORDER, 1)
        html = event
      end
    when "30735-12.html"
      unless has_quest_items?(pc, SOPHYAS_3RD_ORDER)
        give_items(pc, SOPHYAS_3RD_ORDER, 1)
        html = event
      end
    when "30735-13.html"
      unless has_quest_items?(pc, SOPHYAS_4TH_ORDER)
        give_items(pc, SOPHYAS_4TH_ORDER, 1)
        html = event
      end
    when "30735-16.html"
      if get_quest_items_count(pc, LIONS_CLAW) < 10
        html = event
      elsif get_quest_items_count(pc, LIONS_CLAW) >= 10 && get_quest_items_count(pc, LIONS_EYE) < 4
        give_items(pc, LIONS_EYE, 1)
        if chance < 25
          give_items(pc, HEALING_POTION, 20)
        elsif chance < 50
          if pc.in_category?(CategoryType::FIGHTER_GROUP)
            give_items(pc, SOULSHOT_D_GRADE, 100)
          elsif pc.in_category?(CategoryType::MAGE_GROUP)
            give_items(pc, SPIRITSHOT_D_GRADE, 50)
          end
        elsif chance < 75
          give_items(pc, SCROLL_OF_ESCAPE, 20)
        else
          give_items(pc, ALACRITY_POTION, 3)
        end
        take_items(pc, LIONS_CLAW, 10)
        html = "30735-17a.html"
      elsif get_quest_items_count(pc, LIONS_CLAW) >= 10 && get_quest_items_count(pc, LIONS_EYE) >= 4 && get_quest_items_count(pc, LIONS_EYE) <= 7
        give_items(pc, LIONS_EYE, 1)
        if chance < 25
          give_items(pc, HEALING_POTION, 25)
        elsif chance < 50
          if pc.in_category?(CategoryType::FIGHTER_GROUP)
            give_items(pc, SOULSHOT_D_GRADE, 200)
          elsif pc.in_category?(CategoryType::MAGE_GROUP)
            give_items(pc, SPIRITSHOT_D_GRADE, 100)
          end
        elsif chance < 75
          give_items(pc, SCROLL_OF_ESCAPE, 20)
        else
          give_items(pc, ALACRITY_POTION, 3)
        end
        take_items(pc, LIONS_CLAW, 10)
        html = "30735-18b.html"
      elsif get_quest_items_count(pc, LIONS_CLAW) >= 10 && get_quest_items_count(pc, LIONS_EYE) >= 8
        take_items(pc, LIONS_EYE, 8)
        if chance < 25
          give_items(pc, HEALING_POTION, 50)
        elsif chance < 50
          if pc.in_category?(CategoryType::FIGHTER_GROUP)
            give_items(pc, SOULSHOT_D_GRADE, 400)
          elsif pc.in_category?(CategoryType::MAGE_GROUP)
            give_items(pc, SPIRITSHOT_D_GRADE, 200)
          end
        elsif chance < 75
          give_items(pc, SCROLL_OF_ESCAPE, 30)
        else
          give_items(pc, ALACRITY_POTION, 4)
        end
        take_items(pc, LIONS_CLAW, 10)
        html = "30735-19b.html"
      end
    when "30735-20.html"
      take_items(pc, SOPHYAS_1ST_ORDER, -1)
      take_items(pc, SOPHYAS_2ND_ORDER, -1)
      take_items(pc, SOPHYAS_3RD_ORDER, -1)
      take_items(pc, SOPHYAS_4TH_ORDER, -1)
      html = event
    when "30735-26.html"
      if has_quest_items?(pc, BLACK_LION_MARK)
        give_adena(pc, 12400, true)
        qs.exit_quest(true, true)
        html = event
      end
    when "30130-04.html"
      if has_quest_items?(pc, COMPLETE_STATUE_OF_SHILEN)
        give_adena(pc, 30000, true)
        take_items(pc, COMPLETE_STATUE_OF_SHILEN, 1)
        html = event
      end
    when "30471-03.html"
      if !has_quest_items?(pc, STATUE_OF_SHILEN_HEAD, STATUE_OF_SHILEN_TORSO, STATUE_OF_SHILEN_ARM, STATUE_OF_SHILEN_LEG)
        html = event
      else
        if Rnd.rand(100) < 50
          give_items(pc, COMPLETE_STATUE_OF_SHILEN, 1)
          take_items(pc, STATUE_OF_SHILEN_HEAD, 1)
          take_items(pc, STATUE_OF_SHILEN_TORSO, 1)
          take_items(pc, STATUE_OF_SHILEN_ARM, 1)
          take_items(pc, STATUE_OF_SHILEN_LEG, 1)
          html = "30471-04.html"
        else
          take_items(pc, STATUE_OF_SHILEN_HEAD, 1)
          take_items(pc, STATUE_OF_SHILEN_TORSO, 1)
          take_items(pc, STATUE_OF_SHILEN_ARM, 1)
          take_items(pc, STATUE_OF_SHILEN_LEG, 1)
          html = "30471-05.html"
        end
      end
    when "30471-06.html"
      if !has_quest_items?(pc, FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE, FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE, FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE, FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE)
        html = event
      else
        if Rnd.rand(100) < 50
          give_items(pc, COMPLETE_ANCIENT_TABLET, 1)
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE, 1)
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE, 1)
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE, 1)
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE, 1)
          html = "30471-07.html"
        else
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE, 1)
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE, 1)
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE, 1)
          take_items(pc, FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE, 1)
          html = "30471-08.html"
        end
      end
    when "30531-04.html"
      if has_quest_items?(pc, COMPLETE_ANCIENT_TABLET)
        give_adena(pc, 30000, true)
        take_items(pc, COMPLETE_ANCIENT_TABLET, 1)
        html = event
      end
    when "30736-03.html"
      if get_quest_items_count(pc, Inventory::ADENA_ID) < 650 && get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) >= 1
        html = event
      elsif get_quest_items_count(pc, Inventory::ADENA_ID) >= 650 && get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) >= 1
        take_items(pc, Inventory::ADENA_ID, 650)
        if has_quest_items?(pc, CARGO_BOX_1ST)
          take_items(pc, CARGO_BOX_1ST, 1)
        elsif has_quest_items?(pc, CARGO_BOX_2ND)
          take_items(pc, CARGO_BOX_2ND, 1)
        elsif has_quest_items?(pc, CARGO_BOX_3RD)
          take_items(pc, CARGO_BOX_3RD, 1)
        elsif has_quest_items?(pc, CARGO_BOX_4TH)
          take_items(pc, CARGO_BOX_4TH, 1)
        end

        if chance < 40
          if chance1 < 33
            give_items(pc, GLUDIO_APPLES, 1)
            html = "30736-04a.html"
          elsif chance1 < 66
            give_items(pc, DION_CORN_MEAL, 1)
            html = "30736-04b.html"
          else
            give_items(pc, DIRE_WOLF_PELTS, 1)
            html = "30736-04c.html"
          end
        elsif chance < 60
          if chance1 < 33
            give_items(pc, MOONSTONE, 1)
            html = "30736-04d.html"
          elsif chance1 < 66
            give_items(pc, GLUDIO_WHEAT_FLOUR, 1)
            html = "30736-04e.html"
          else
            give_items(pc, SPIDERSILK_ROPE, 1)
            html = "30736-04f.html"
          end
        elsif chance < 70
          if chance1 < 33
            give_items(pc, ALEXANDRITE, 1)
            html = "30736-04g.html"
          elsif chance1 < 66
            give_items(pc, SILVER_TEA_SERVICE, 1)
            html = "30736-04h.html"
          else
            give_items(pc, MECHANIC_GOLEM_SPACE_PARTS, 1)
            html = "30736-04i.html"
          end
        elsif chance < 75
          if chance1 < 33
            give_items(pc, FIRE_EMERALD, 1)
            html = "30736-04j.html"
          elsif chance1 < 66
            give_items(pc, AVELLAN_SILK_FROCK, 1)
            html = "30736-04k.html"
          else
            give_items(pc, FERIOTIC_PORCELAIN_URM, 1)
            html = "30736-04l.html"
          end
        elsif chance < 76
          give_items(pc, IMPERIAL_DIAMOND, 1)
          html = "30736-04m.html"
        elsif Rnd.rand(100) < 50
          if chance1 < 25
            give_items(pc, STATUE_OF_SHILEN_HEAD, 1)
          elsif chance1 < 50
            give_items(pc, STATUE_OF_SHILEN_TORSO, 1)
          elsif chance1 < 75
            give_items(pc, STATUE_OF_SHILEN_ARM, 1)
          else
            give_items(pc, STATUE_OF_SHILEN_LEG, 1)
          end
          html = "30736-04n.html"
        else
          if chance1 < 25
            give_items(pc, FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE, 1)
          elsif chance1 < 50
            give_items(pc, FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE, 1)
          elsif chance1 < 75
            give_items(pc, FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE, 1)
          else
            give_items(pc, FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE, 1)
          end
          html = "30736-04o.html"
        end
      elsif get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) < 1
        html = "30736-05.html"
      end
    when "30736-07.html"
      if pc.adena < 200 + (qs.memo_state * 200)
        html = event
      elsif qs.memo_state * 100 > 200
        html = "30736-08.html"
      else
        if chance < 5
          html = "30736-08a.html"
        elsif chance < 10
          html = "30736-08b.html"
        elsif chance < 15
          html = "30736-08c.html"
        elsif chance < 20
          html = "30736-08d.html"
        elsif chance < 25
          html = "30736-08e.html"
        elsif chance < 30
          html = "30736-08f.html"
        elsif chance < 35
          html = "30736-08g.html"
        elsif chance < 40
          html = "30736-08h.html"
        elsif chance < 45
          html = "30736-08i.html"
        elsif chance < 50
          html = "30736-08j.html"
        elsif chance < 55
          html = "30736-08k.html"
        elsif chance < 60
          html = "30736-08l.html"
        elsif chance < 65
          html = "30736-08m.html"
        elsif chance < 70
          html = "30736-08n.html"
        elsif chance < 75
          html = "30736-08o.html"
        elsif chance < 80
          html = "30736-08p.html"
        elsif chance < 85
          html = "30736-08q.html"
        elsif chance < 90
          html = "30736-08r.html"
        elsif chance < 95
          html = "30736-08s.html"
        else
          html = "30736-08t.html"
        end
        take_items(pc, Inventory::ADENA_ID, 200 + (qs.memo_state * 200))
        qs.memo_state += 1
      end
    when "30737-06.html"
      if get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) < 1
        html = event
      else
        if has_quest_items?(pc, CARGO_BOX_1ST)
          take_items(pc, CARGO_BOX_1ST, 1)
        elsif has_quest_items?(pc, CARGO_BOX_2ND)
          take_items(pc, CARGO_BOX_2ND, 1)
        elsif has_quest_items?(pc, CARGO_BOX_3RD)
          take_items(pc, CARGO_BOX_3RD, 1)
        elsif has_quest_items?(pc, CARGO_BOX_4TH)
          take_items(pc, CARGO_BOX_4TH, 1)
        end

        if get_quest_items_count(pc, GUILD_COIN) < 80
          give_items(pc, GUILD_COIN, 1)
        else
          take_items(pc, GUILD_COIN, 80)
        end

        if get_quest_items_count(pc, GUILD_COIN) < 40
          give_adena(pc, 100, true)
          html = "30737-03.html"
        elsif get_quest_items_count(pc, GUILD_COIN) >= 40 && get_quest_items_count(pc, GUILD_COIN) < 80
          give_adena(pc, 200, true)
          html = "30737-04.html"
        else
          give_adena(pc, 300, true)
          html = "30737-05.html"
        end
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when MARSH_STAKATO
        if has_quest_items?(killer, SOPHYAS_4TH_ORDER)
          if Rnd.rand(100) < 55
            give_items(killer, STAKATO_TALON, 1)
          end
          if Rnd.rand(100) < 12
            give_items(killer, CARGO_BOX_4TH, 1)
          end
          if Rnd.rand(100) < 2 && has_quest_items?(killer, SOPHYAS_4TH_ORDER)
            add_spawn(MARSH_STAKATO_MARQUESS, npc, true, 0, false)
          end
        end
      when NEER_CRAWLER
        if has_quest_items?(killer, SOPHYAS_1ST_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, UNDEAD_ASH, 1)
          end
          if Rnd.rand(100) < 11
            give_items(killer, CARGO_BOX_1ST, 1)
          end
        end
      when SPECTER
        if has_quest_items?(killer, SOPHYAS_1ST_ORDER)
          if Rnd.rand(100) < 60
            give_items(killer, UNDEAD_ASH, 1)
          end
          if Rnd.rand(100) < 8
            give_items(killer, CARGO_BOX_1ST, 1)
          end
        end
      when SORROW_MAIDEN
        if has_quest_items?(killer, SOPHYAS_1ST_ORDER)
          if Rnd.rand(100) < 60
            give_items(killer, UNDEAD_ASH, 1)
          end
          if Rnd.rand(100) < 9
            give_items(killer, CARGO_BOX_1ST, 1)
          end
        end
      when NEER_CRAWLER_BERSERKER
        if has_quest_items?(killer, SOPHYAS_1ST_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, UNDEAD_ASH, 1)
          end
          if Rnd.rand(100) < 12
            give_items(killer, CARGO_BOX_1ST, 1)
          end
        end
      when STRAIN
        if has_quest_items?(killer, SOPHYAS_1ST_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, UNDEAD_ASH, 1)
          end
          if Rnd.rand(100) < 13
            give_items(killer, CARGO_BOX_1ST, 1)
          end
        end
      when GHOUL
        if has_quest_items?(killer, SOPHYAS_1ST_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, UNDEAD_ASH, 1)
          end
          if Rnd.rand(100) < 15
            give_items(killer, CARGO_BOX_1ST, 1)
          end
        end
      when OL_MAHUM_GUERILLA
        if has_quest_items?(killer, SOPHYAS_2ND_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, BLOODY_AXE_INSIGNIA, 1)
          end
          if Rnd.rand(100) < 9
            give_items(killer, CARGO_BOX_2ND, 1)
          end
        end
      when OL_MAHUM_RAIDER
        if has_quest_items?(killer, SOPHYAS_2ND_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, BLOODY_AXE_INSIGNIA, 1)
          end
          if Rnd.rand(100) < 10
            give_items(killer, CARGO_BOX_2ND, 1)
          end
        end
      when OL_MAHUM_MARKSMAN
        if has_quest_items?(killer, SOPHYAS_2ND_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, BLOODY_AXE_INSIGNIA, 1)
          end
          if Rnd.rand(100) < 11
            give_items(killer, CARGO_BOX_2ND, 1)
          end
        end
      when OL_MAHUM_SERGEANT
        if has_quest_items?(killer, SOPHYAS_2ND_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, BLOODY_AXE_INSIGNIA, 1)
          end
          if Rnd.rand(100) < 12
            give_items(killer, CARGO_BOX_2ND, 1)
          end
        end
      when OL_MAHUM_CAPTAIN
        if has_quest_items?(killer, SOPHYAS_2ND_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, BLOODY_AXE_INSIGNIA, 1)
          end
          if Rnd.rand(100) < 13
            give_items(killer, CARGO_BOX_2ND, 1)
          end
        end
      when MARSH_STAKATO_WORKER
        if has_quest_items?(killer, SOPHYAS_4TH_ORDER)
          if Rnd.rand(100) < 60
            give_items(killer, STAKATO_TALON, 1)
          end
          if Rnd.rand(100) < 13
            give_items(killer, CARGO_BOX_4TH, 1)
          end
          if Rnd.rand(100) < 2 && has_quest_items?(killer, SOPHYAS_4TH_ORDER)
            add_spawn(MARSH_STAKATO_MARQUESS, npc, true, 0, false)
          end
        end
      when MARSH_STAKATO_SOLDIER
        if has_quest_items?(killer, SOPHYAS_4TH_ORDER)
          if Rnd.rand(100) < 56
            give_items(killer, STAKATO_TALON, 1)
          end
          if Rnd.rand(100) < 14
            give_items(killer, CARGO_BOX_4TH, 1)
          end
          if Rnd.rand(100) < 2 && has_quest_items?(killer, SOPHYAS_4TH_ORDER)
            add_spawn(MARSH_STAKATO_MARQUESS, npc, true, 0, false)
          end
        end
      when MARSH_STAKATO_DRONE
        if has_quest_items?(killer, SOPHYAS_4TH_ORDER)
          if Rnd.rand(100) < 60
            give_items(killer, STAKATO_TALON, 1)
          end
          if Rnd.rand(100) < 15
            give_items(killer, CARGO_BOX_4TH, 1)
          end
          if Rnd.rand(100) < 2 && has_quest_items?(killer, SOPHYAS_4TH_ORDER)
            add_spawn(MARSH_STAKATO_MARQUESS, npc, true, 0, false)
          end
        end
      when DELU_LIZARDMAN, DELU_LIZARDMAN_SCOUT
        if has_quest_items?(killer, SOPHYAS_3RD_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, DELU_LIZARDMAN_FANG, 1)
          end
          if Rnd.rand(100) < 14
            give_items(killer, CARGO_BOX_3RD, 1)
          end
        end
        if Rnd.rand(100) < 3 && has_quest_items?(killer, SOPHYAS_3RD_ORDER)
          add_spawn(DELU_LIZARDMAN_HEADHUNTER, npc, true, 0, false)
          add_spawn(DELU_LIZARDMAN_HEADHUNTER, npc, true, 0, false)
        end
      when DELU_LIZARDMAN_WARRIOR
        if has_quest_items?(killer, SOPHYAS_3RD_ORDER)
          if Rnd.rand(2) == 0
            give_items(killer, DELU_LIZARDMAN_FANG, 1)
          end
          if Rnd.rand(100) < 15
            give_items(killer, CARGO_BOX_3RD, 1)
          end
        end
        if Rnd.rand(100) < 3 && has_quest_items?(killer, SOPHYAS_3RD_ORDER)
          add_spawn(DELU_LIZARDMAN_HEADHUNTER, npc, true, 0, false)
          add_spawn(DELU_LIZARDMAN_HEADHUNTER, npc, true, 0, false)
        end
      when DELU_LIZARDMAN_HEADHUNTER
        if has_quest_items?(killer, SOPHYAS_3RD_ORDER)
          give_items(killer, DELU_LIZARDMAN_FANG, 4)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      when MARSH_STAKATO_MARQUESS
        if has_quest_items?(killer, SOPHYAS_4TH_ORDER)
          give_items(killer, STAKATO_TALON, 8)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == MERCENARY_CAPTAIN_SOPHYA
        if pc.level < MIN_LEVEL
          html = "30735-01.htm"
        else
          if !has_quest_items?(pc, BLACK_LION_MARK)
            html = "30735-02.htm"
          else
            html = "30735-03.htm"
          end
        end
      end
    elsif qs.started?
      case npc.id
      when MERCENARY_CAPTAIN_SOPHYA
        if get_quest_items_count(pc, SOPHYAS_1ST_ORDER) + get_quest_items_count(pc, SOPHYAS_2ND_ORDER) + get_quest_items_count(pc, SOPHYAS_3RD_ORDER) + get_quest_items_count(pc, SOPHYAS_4TH_ORDER) == 0
          html = "30735-14.html"
        elsif get_quest_items_count(pc, SOPHYAS_1ST_ORDER) + get_quest_items_count(pc, SOPHYAS_2ND_ORDER) + get_quest_items_count(pc, SOPHYAS_3RD_ORDER) + get_quest_items_count(pc, SOPHYAS_4TH_ORDER) == 1 && get_quest_items_count(pc, UNDEAD_ASH) + get_quest_items_count(pc, BLOODY_AXE_INSIGNIA) + get_quest_items_count(pc, DELU_LIZARDMAN_FANG) + get_quest_items_count(pc, STAKATO_TALON) < 1 && get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) < 1
          html = "30735-15.html"
        elsif get_quest_items_count(pc, SOPHYAS_1ST_ORDER) + get_quest_items_count(pc, SOPHYAS_2ND_ORDER) + get_quest_items_count(pc, SOPHYAS_3RD_ORDER) + get_quest_items_count(pc, SOPHYAS_4TH_ORDER) == 1 && get_quest_items_count(pc, UNDEAD_ASH) + get_quest_items_count(pc, BLOODY_AXE_INSIGNIA) + get_quest_items_count(pc, DELU_LIZARDMAN_FANG) + get_quest_items_count(pc, STAKATO_TALON) < 1 && get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) >= 1
          html = "30735-15a.html"
        elsif get_quest_items_count(pc, SOPHYAS_1ST_ORDER) + get_quest_items_count(pc, SOPHYAS_2ND_ORDER) + get_quest_items_count(pc, SOPHYAS_3RD_ORDER) + get_quest_items_count(pc, SOPHYAS_4TH_ORDER) == 1 && get_quest_items_count(pc, UNDEAD_ASH) + get_quest_items_count(pc, BLOODY_AXE_INSIGNIA) + get_quest_items_count(pc, DELU_LIZARDMAN_FANG) + get_quest_items_count(pc, STAKATO_TALON) >= 1 && get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) == 0
          itemcount = get_quest_items_count(pc, UNDEAD_ASH) + get_quest_items_count(pc, BLOODY_AXE_INSIGNIA) + get_quest_items_count(pc, DELU_LIZARDMAN_FANG) + get_quest_items_count(pc, STAKATO_TALON)
          if itemcount < 20

          elsif itemcount < 50
            give_items(pc, LIONS_CLAW, 1)
          elsif itemcount < 100
            give_items(pc, LIONS_CLAW, 2)
          else
            give_items(pc, LIONS_CLAW, 3)
          end
          ash = get_quest_items_count(pc, UNDEAD_ASH)
          insignia = get_quest_items_count(pc, BLOODY_AXE_INSIGNIA)
          fang = get_quest_items_count(pc, DELU_LIZARDMAN_FANG)
          talon = get_quest_items_count(pc, STAKATO_TALON)
          give_adena(pc, (ash * 35) + (insignia * 35) + fang + 35 + (talon * 35), true)
          take_items(pc, UNDEAD_ASH, -1)
          take_items(pc, BLOODY_AXE_INSIGNIA, -1)
          take_items(pc, DELU_LIZARDMAN_FANG, -1)
          take_items(pc, STAKATO_TALON, -1)
          qs.memo_state = 0
          html = "30735-22.html"
        elsif get_quest_items_count(pc, SOPHYAS_1ST_ORDER) + get_quest_items_count(pc, SOPHYAS_2ND_ORDER) + get_quest_items_count(pc, SOPHYAS_3RD_ORDER) + get_quest_items_count(pc, SOPHYAS_4TH_ORDER) == 1 && get_quest_items_count(pc, UNDEAD_ASH) + get_quest_items_count(pc, BLOODY_AXE_INSIGNIA) + get_quest_items_count(pc, DELU_LIZARDMAN_FANG) + get_quest_items_count(pc, STAKATO_TALON) >= 1 && get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) >= 1
          itemcount = get_quest_items_count(pc, UNDEAD_ASH) + get_quest_items_count(pc, BLOODY_AXE_INSIGNIA) + get_quest_items_count(pc, DELU_LIZARDMAN_FANG) + get_quest_items_count(pc, STAKATO_TALON)
          if itemcount < 20

          elsif itemcount < 50
            give_items(pc, LIONS_CLAW, 1)
          elsif itemcount < 100
            give_items(pc, LIONS_CLAW, 2)
          else
            give_items(pc, LIONS_CLAW, 3)
          end
          give_adena(pc, get_quest_items_count(pc, UNDEAD_ASH) * 35, true)
          give_adena(pc, get_quest_items_count(pc, BLOODY_AXE_INSIGNIA) * 35, true)
          give_adena(pc, get_quest_items_count(pc, DELU_LIZARDMAN_FANG) * 35, true)
          give_adena(pc, get_quest_items_count(pc, STAKATO_TALON) * 35, true)
          take_items(pc, UNDEAD_ASH, -1)
          take_items(pc, BLOODY_AXE_INSIGNIA, -1)
          take_items(pc, DELU_LIZARDMAN_FANG, -1)
          take_items(pc, STAKATO_TALON, -1)
          qs.memo_state = 0
          html = "30735-23.html"
        end
      when ABYSSAL_CELEBRANT_UNDRIAS
        if !has_quest_items?(pc, COMPLETE_STATUE_OF_SHILEN)
          if get_quest_items_count(pc, STATUE_OF_SHILEN_HEAD) + get_quest_items_count(pc, STATUE_OF_SHILEN_TORSO) + get_quest_items_count(pc, STATUE_OF_SHILEN_ARM) + get_quest_items_count(pc, STATUE_OF_SHILEN_LEG) >= 1
            html = "30130-02.html"
          else
            html = "30130-01.html"
          end
        else
          html = "30130-03.html"
        end
      when BLACKSMITH_RUPIO
        if get_quest_items_count(pc, STATUE_OF_SHILEN_HEAD) + get_quest_items_count(pc, STATUE_OF_SHILEN_TORSO) + get_quest_items_count(pc, STATUE_OF_SHILEN_ARM) + get_quest_items_count(pc, STATUE_OF_SHILEN_LEG) >= 1 || get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE) + get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE) + get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE) + get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE) >= 1
          html = "30471-02.html"
        else
          html = "30471-01.html"
        end
      when IRON_GATES_LOCKIRIN
        if !has_quest_items?(pc, COMPLETE_ANCIENT_TABLET)
          if get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_1ST_PIECE) + get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_2ND_PIECE) + get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_3RD_PIECE) + get_quest_items_count(pc, FRAGMENT_OF_ANCIENT_TABLET_4TH_PIECE) >= 1
            html = "30531-02.html"
          else
            html = "30531-01.html"
          end
        else
          html = "30531-03.html"
        end
      when MERCENARY_REEDFOOT
        if get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) >= 1
          html = "30736-02.html"
        else
          html = "30736-01.html"
        end
      when GUILDSMAN_MORGON
        if get_quest_items_count(pc, CARGO_BOX_1ST) + get_quest_items_count(pc, CARGO_BOX_2ND) + get_quest_items_count(pc, CARGO_BOX_3RD) + get_quest_items_count(pc, CARGO_BOX_4TH) >= 1
          html = "30737-02.html"
        else
          html = "30737-01.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
