class Scripts::Q00372_LegacyOfInsolence < Quest
  # NPCs
  private TRADER_HOLLY = 30839
  private WAREHOUSE_KEEPER_WALDERAL = 30844
  private MAGISTER_DESMOND = 30855
  private ANTIQUE_DEALER_PATRIN = 30929
  private CLAUDIA_ATHEBALDT = 31001
  # Items
  private ANCIENT_RED_PAPYRUS = 5966
  private ANCIENT_BLUE_PAPYRUS = 5967
  private ANCIENT_BLACK_PAPYRUS = 5968
  private ANCIENT_WHITE_PAPYRUS = 5969
  private REVELATION_OF_THE_SEALS_CHAPTER_OF_AVARICE = 5972
  private REVELATION_OF_THE_SEALS_CHAPTER_OF_GNOSIS = 5973
  private REVELATION_OF_THE_SEALS_CHAPTER_OF_STRIFE = 5974
  private REVELATION_OF_THE_SEALS_CHAPTER_OF_VENGEANCE = 5975
  private REVELATION_OF_THE_SEALS_CHAPTER_OF_AWEKENING = 5976
  private REVELATION_OF_THE_SEALS_CHAPTER_OF_CALAMITY = 5977
  private REVELATION_OF_THE_SEALS_CHAPTER_OF_DESCENT = 5978
  private ANCIENT_EPIC_CHAPTER_1 = 5979
  private ANCIENT_EPIC_CHAPTER_2 = 5980
  private ANCIENT_EPIC_CHAPTER_3 = 5981
  private ANCIENT_EPIC_CHAPTER_4 = 5982
  private ANCIENT_EPIC_CHAPTER_5 = 5983
  private IMPERIAL_GENEALOGY_1 = 5984
  private IMPERIAL_GENEALOGY_2 = 5985
  private IMPERIAL_GENEALOGY_3 = 5986
  private IMPERIAL_GENEALOGY_4 = 5987
  private IMPERIAL_GENEALOGY_5 = 5988
  private BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR = 5989
  private BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR = 5990
  private BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR = 5991
  private BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR = 5992
  private BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR = 5993
  private BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR = 5994
  private BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR = 5995
  private BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR = 5996
  private BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR = 5997
  private BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR = 5998
  private BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR = 5999
  private BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR = 6000
  private BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR = 6001
  # Rewards
  private RECIPE_SEALED_DARK_CRYSTAL_BOOTS_60 = 5368
  private RECIPE_SEALED_TALLUM_BOOTS_60 = 5370
  private RECIPE_SEALED_BOOTS_OF_NIGHTMARE_60 = 5380
  private RECIPE_SEALED_MAJESTIC_BOOTS_60 = 5382
  private RECIPE_SEALED_DARK_CRYSTAL_GLOVES_60 = 5392
  private RECIPE_SEALED_TALLUM_GLOVES_60 = 5394
  private RECIPE_SEALED_GAUNTLETS_OF_NIGHTMARE_60 = 5404
  private RECIPE_SEALED_MAJESTIC_GAUNTLETS_60 = 5406
  private RECIPE_SEALED_DARK_CRYSTAL_HELMET_60 = 5426
  private RECIPE_SEALED_TALLUM_HELMET_60 = 5428
  private RECIPE_SEALED_HELM_OF_NIGHTMARE_60 = 5430
  private RECIPE_SEALED_MAJESTIC_CIRCLET_60 = 5432
  private SEALED_DARK_CRYSTAL_BOOTS_LINING = 5496
  private SEALED_TALLUM_BOOTS_LINING = 5497
  private SEALED_BOOTS_OF_NIGHTMARE_LINING = 5502
  private SEALED_MAJESTIC_BOOTS_LINING = 5503
  private SEALED_DARK_CRYSTAL_GLOVES_DESIGN = 5508
  private SEALED_TALLUM_GLOVES_DESIGN = 5509
  private SEALED_GAUNTLETS_OF_NIGHTMARE_DESIGN = 5514
  private SEALED_MAJESTIC_GAUNTLETS_DESIGN = 5515
  private SEALED_DARK_CRYSTAL_HELMET_DESIGN = 5525
  private SEALED_TALLUM_HELM_DESIGN = 5526
  private SEALED_HELM_OF_NIGHTMARE_DESIGN = 5527
  private SEALED_MAJESTIC_CIRCLET_DESIGN = 5528
  # Monsters
  private HALLATES_INSPECTOR = 20825
  private MONSTER_REWARDS = {
    20817 => QuestItemHolder.new(ANCIENT_RED_PAPYRUS, 302, 1),
    20821 => QuestItemHolder.new(ANCIENT_RED_PAPYRUS, 410, 1),
    HALLATES_INSPECTOR => QuestItemHolder.new(ANCIENT_RED_PAPYRUS, 447, 1),
    20829 => QuestItemHolder.new(ANCIENT_BLUE_PAPYRUS, 451, 1),
    21062 => QuestItemHolder.new(ANCIENT_WHITE_PAPYRUS, 290, 1),
    21069 => QuestItemHolder.new(ANCIENT_BLACK_PAPYRUS, 280, 1)
  }

  # Misc
  private MIN_LEVEL = 59

  def initialize
    super(372, self.class.simple_name, "Legacy Of Insolence")

    add_start_npc(WAREHOUSE_KEEPER_WALDERAL)
    add_talk_id(
      WAREHOUSE_KEEPER_WALDERAL, TRADER_HOLLY, MAGISTER_DESMOND,
      ANTIQUE_DEALER_PATRIN, CLAUDIA_ATHEBALDT
    )
    add_kill_id(MONSTER_REWARDS.keys)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return super
    end
    chance = Rnd.rand(100)

    case event
    when "30844-04.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30844-07.html"
      if has_quest_items?(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR)
        html = event
      else
        html = "30844-06.html"
      end
    when "30844-09.html"
      qs.exit_quest(true, true)
      html = event
    when "30844-07a.html"
      if has_quest_items?(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR, 1)

        if chance < 10
          give_items(pc, SEALED_DARK_CRYSTAL_BOOTS_LINING, 1)
        elsif chance < 20
          give_items(pc, SEALED_DARK_CRYSTAL_GLOVES_DESIGN, 1)
        elsif chance < 30
          give_items(pc, SEALED_DARK_CRYSTAL_HELMET_DESIGN, 1)
        elsif chance < 40
          give_items(pc, SEALED_DARK_CRYSTAL_BOOTS_LINING, 1)
          give_items(pc, SEALED_DARK_CRYSTAL_GLOVES_DESIGN, 1)
          give_items(pc, SEALED_DARK_CRYSTAL_HELMET_DESIGN, 1)
        elsif chance < 51
          give_items(pc, RECIPE_SEALED_DARK_CRYSTAL_BOOTS_60, 1)
        elsif chance < 62
          give_items(pc, RECIPE_SEALED_DARK_CRYSTAL_GLOVES_60, 1)
        elsif chance < 79
          give_items(pc, RECIPE_SEALED_DARK_CRYSTAL_HELMET_60, 1)
        elsif chance < 100
          give_items(pc, RECIPE_SEALED_DARK_CRYSTAL_BOOTS_60, 1)
          give_items(pc, RECIPE_SEALED_DARK_CRYSTAL_GLOVES_60, 1)
          give_items(pc, RECIPE_SEALED_DARK_CRYSTAL_HELMET_60, 1)
        end
        html = event
      else
        html = "30844-07e.html"
      end
    when "30844-07b.html"
      if has_quest_items?(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR, 1)

        if chance < 10
          give_items(pc, SEALED_TALLUM_BOOTS_LINING, 1)
        elsif chance < 20
          give_items(pc, SEALED_TALLUM_GLOVES_DESIGN, 1)
        elsif chance < 30
          give_items(pc, SEALED_TALLUM_HELM_DESIGN, 1)
        elsif chance < 40
          give_items(pc, SEALED_TALLUM_BOOTS_LINING, 1)
          give_items(pc, SEALED_TALLUM_GLOVES_DESIGN, 1)
          give_items(pc, SEALED_TALLUM_HELM_DESIGN, 1)
        elsif chance < 51
          give_items(pc, RECIPE_SEALED_TALLUM_BOOTS_60, 1)
        elsif chance < 62
          give_items(pc, RECIPE_SEALED_TALLUM_GLOVES_60, 1)
        elsif chance < 79
          give_items(pc, RECIPE_SEALED_TALLUM_HELMET_60, 1)
        elsif chance < 100
          give_items(pc, RECIPE_SEALED_TALLUM_BOOTS_60, 1)
          give_items(pc, RECIPE_SEALED_TALLUM_GLOVES_60, 1)
          give_items(pc, RECIPE_SEALED_TALLUM_HELMET_60, 1)
        end
        html = event
      else
        html = "30844-07e.html"
      end
    when "30844-07c.html"
      if has_quest_items?(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR, 1)

        if chance < 17
          give_items(pc, SEALED_BOOTS_OF_NIGHTMARE_LINING, 1)
        elsif chance < 34
          give_items(pc, SEALED_GAUNTLETS_OF_NIGHTMARE_DESIGN, 1)
        elsif chance < 49
          give_items(pc, SEALED_HELM_OF_NIGHTMARE_DESIGN, 1)
        elsif chance < 58
          give_items(pc, SEALED_BOOTS_OF_NIGHTMARE_LINING, 1)
          give_items(pc, SEALED_GAUNTLETS_OF_NIGHTMARE_DESIGN, 1)
          give_items(pc, SEALED_HELM_OF_NIGHTMARE_DESIGN, 1)
        elsif chance < 70
          give_items(pc, RECIPE_SEALED_BOOTS_OF_NIGHTMARE_60, 1)
        elsif chance < 82
          give_items(pc, RECIPE_SEALED_GAUNTLETS_OF_NIGHTMARE_60, 1)
        elsif chance < 92
          give_items(pc, RECIPE_SEALED_HELM_OF_NIGHTMARE_60, 1)
        elsif chance < 100
          give_items(pc, RECIPE_SEALED_BOOTS_OF_NIGHTMARE_60, 1)
          give_items(pc, RECIPE_SEALED_GAUNTLETS_OF_NIGHTMARE_60, 1)
          give_items(pc, RECIPE_SEALED_HELM_OF_NIGHTMARE_60, 1)
        end
        html = event
      else
        html = "30844-07e.html"
      end
    when "30844-07d.html"
      if has_quest_items?(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_1ST_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_2ND_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_3RD_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_4TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_5TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_6TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_7TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_8TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_9TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_10TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_11TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_12TH_FLOOR, 1)
        take_items(pc, BLUEPRINT_TOWER_OF_INSOLENCE_13TH_FLOOR, 1)

        if chance < 17
          give_items(pc, SEALED_MAJESTIC_BOOTS_LINING, 1)
        elsif chance < 34
          give_items(pc, SEALED_MAJESTIC_GAUNTLETS_DESIGN, 1)
        elsif chance < 49
          give_items(pc, SEALED_MAJESTIC_CIRCLET_DESIGN, 1)
        elsif chance < 58
          give_items(pc, SEALED_MAJESTIC_BOOTS_LINING, 1)
          give_items(pc, SEALED_MAJESTIC_GAUNTLETS_DESIGN, 1)
          give_items(pc, SEALED_MAJESTIC_CIRCLET_DESIGN, 1)
        elsif chance < 70
          give_items(pc, RECIPE_SEALED_MAJESTIC_BOOTS_60, 1)
        elsif chance < 82
          give_items(pc, RECIPE_SEALED_MAJESTIC_GAUNTLETS_60, 1)
        elsif chance < 92
          give_items(pc, RECIPE_SEALED_MAJESTIC_CIRCLET_60, 1)
        elsif chance < 100
          give_items(pc, RECIPE_SEALED_MAJESTIC_BOOTS_60, 1)
          give_items(pc, RECIPE_SEALED_MAJESTIC_GAUNTLETS_60, 1)
          give_items(pc, RECIPE_SEALED_MAJESTIC_CIRCLET_60, 1)
        end
        html = event
      else
        html = "30844-07e.html"
      end
    when "30844-05b.html"
      qs.set_cond(2)
      html = event
    when "30844-03.htm", "30844-05.html", "30844-05a.html", "30844-08.html",
         "30844-10.html", "30844-11.html"
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    item = MONSTER_REWARDS[npc.id]
    if npc.id == HALLATES_INSPECTOR
      if Rnd.rand(1000) < item.chance
        if qs = get_random_party_member_state(killer, -1, 3, npc)
          give_items(qs.player, item.id, item.count)
          play_sound(qs.player, Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end

      return super
    end

    if Util.in_range?(1500, npc, killer, true) && Rnd.rand(1000) < item.chance
      winner = nil
      party = killer.party
      if party.nil?
        qs = get_quest_state(killer, false)
        if qs && qs.started?
          winner = killer
        end
      else
        chance = 0
        party.members.each do |m|
          m_qs = get_quest_state(m, false)
          if m_qs && m_qs.started?
            chance2 = Rnd.rand(1000)
            if chance < chance2
              chance = chance2
              winner = m
            end
          end
        end
      end

      if winner && Util.in_range?(1500, npc, winner, true)
        give_items(winner, item.id, item.count)
        play_sound(winner, Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    chance = Rnd.rand(100)

    if qs.created?
      if npc.id == WAREHOUSE_KEEPER_WALDERAL
        if pc.level < MIN_LEVEL
          html = "30844-01.htm"
        else
          html = "30844-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when WAREHOUSE_KEEPER_WALDERAL
        html = "30844-05.html"
      when TRADER_HOLLY
        if has_quest_items?(pc, IMPERIAL_GENEALOGY_1, IMPERIAL_GENEALOGY_2, IMPERIAL_GENEALOGY_3, IMPERIAL_GENEALOGY_4, IMPERIAL_GENEALOGY_5)
          take_items(pc, IMPERIAL_GENEALOGY_1, 1)
          take_items(pc, IMPERIAL_GENEALOGY_2, 1)
          take_items(pc, IMPERIAL_GENEALOGY_3, 1)
          take_items(pc, IMPERIAL_GENEALOGY_4, 1)
          take_items(pc, IMPERIAL_GENEALOGY_5, 1)

          if chance < 30
            give_items(pc, SEALED_DARK_CRYSTAL_BOOTS_LINING, 1)
          elsif chance < 60
            give_items(pc, SEALED_DARK_CRYSTAL_GLOVES_DESIGN, 1)
          elsif chance < 80
            give_items(pc, SEALED_DARK_CRYSTAL_HELMET_DESIGN, 1)
          elsif chance < 90
            give_items(pc, SEALED_DARK_CRYSTAL_BOOTS_LINING, 1)
            give_items(pc, SEALED_DARK_CRYSTAL_GLOVES_DESIGN, 1)
            give_items(pc, SEALED_DARK_CRYSTAL_HELMET_DESIGN, 1)
          elsif chance < 100
            give_adena(pc, 4000, true)
          end
          html = "30839-02.html"
        else
          html = "30839-01.html"
        end
      when MAGISTER_DESMOND
        if has_quest_items?(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_AVARICE, REVELATION_OF_THE_SEALS_CHAPTER_OF_GNOSIS, REVELATION_OF_THE_SEALS_CHAPTER_OF_STRIFE, REVELATION_OF_THE_SEALS_CHAPTER_OF_VENGEANCE, REVELATION_OF_THE_SEALS_CHAPTER_OF_AWEKENING, REVELATION_OF_THE_SEALS_CHAPTER_OF_CALAMITY, REVELATION_OF_THE_SEALS_CHAPTER_OF_DESCENT)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_AVARICE, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_GNOSIS, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_STRIFE, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_VENGEANCE, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_AWEKENING, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_CALAMITY, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_DESCENT, 1)

          if chance < 31
            give_items(pc, SEALED_MAJESTIC_BOOTS_LINING, 1)
          elsif chance < 62
            give_items(pc, SEALED_MAJESTIC_GAUNTLETS_DESIGN, 1)
          elsif chance < 75
            give_items(pc, SEALED_MAJESTIC_CIRCLET_DESIGN, 1)
          elsif chance < 83
            give_items(pc, SEALED_MAJESTIC_BOOTS_LINING, 1)
            give_items(pc, SEALED_MAJESTIC_GAUNTLETS_DESIGN, 1)
            give_items(pc, SEALED_MAJESTIC_CIRCLET_DESIGN, 1)
          elsif chance < 100
            give_adena(pc, 4000, true)
          end
          html = "30855-02.html"
        else
          html = "30855-01.html"
        end
      when ANTIQUE_DEALER_PATRIN
        if has_quest_items?(pc, ANCIENT_EPIC_CHAPTER_1, ANCIENT_EPIC_CHAPTER_2, ANCIENT_EPIC_CHAPTER_3, ANCIENT_EPIC_CHAPTER_4, ANCIENT_EPIC_CHAPTER_5)
          take_items(pc, ANCIENT_EPIC_CHAPTER_1, 1)
          take_items(pc, ANCIENT_EPIC_CHAPTER_2, 1)
          take_items(pc, ANCIENT_EPIC_CHAPTER_3, 1)
          take_items(pc, ANCIENT_EPIC_CHAPTER_4, 1)
          take_items(pc, ANCIENT_EPIC_CHAPTER_5, 1)

          if chance < 30
            give_items(pc, SEALED_TALLUM_BOOTS_LINING, 1)
          elsif chance < 60
            give_items(pc, SEALED_TALLUM_GLOVES_DESIGN, 1)
          elsif chance < 80
            give_items(pc, SEALED_TALLUM_HELM_DESIGN, 1)
          elsif chance < 90
            give_items(pc, SEALED_TALLUM_BOOTS_LINING, 1)
            give_items(pc, SEALED_TALLUM_GLOVES_DESIGN, 1)
            give_items(pc, SEALED_TALLUM_HELM_DESIGN, 1)
          elsif chance < 100
            give_adena(pc, 4000, true)
          end
          html = "30929-02.html"
        else
          html = "30929-02.html"
        end
      when CLAUDIA_ATHEBALDT
        if has_quest_items?(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_AVARICE, REVELATION_OF_THE_SEALS_CHAPTER_OF_GNOSIS, REVELATION_OF_THE_SEALS_CHAPTER_OF_STRIFE, REVELATION_OF_THE_SEALS_CHAPTER_OF_VENGEANCE, REVELATION_OF_THE_SEALS_CHAPTER_OF_AWEKENING, REVELATION_OF_THE_SEALS_CHAPTER_OF_CALAMITY, REVELATION_OF_THE_SEALS_CHAPTER_OF_DESCENT)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_AVARICE, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_GNOSIS, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_STRIFE, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_VENGEANCE, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_AWEKENING, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_CALAMITY, 1)
          take_items(pc, REVELATION_OF_THE_SEALS_CHAPTER_OF_DESCENT, 1)

          if chance < 31
            give_items(pc, SEALED_BOOTS_OF_NIGHTMARE_LINING, 1)
          elsif chance < 62
            give_items(pc, SEALED_GAUNTLETS_OF_NIGHTMARE_DESIGN, 1)
          elsif chance < 75
            give_items(pc, SEALED_HELM_OF_NIGHTMARE_DESIGN, 1)
          elsif chance < 83
            give_items(pc, SEALED_BOOTS_OF_NIGHTMARE_LINING, 1)
            give_items(pc, SEALED_GAUNTLETS_OF_NIGHTMARE_DESIGN, 1)
            give_items(pc, SEALED_HELM_OF_NIGHTMARE_DESIGN, 1)
          elsif chance < 100
            give_adena(pc, 4000, true)
          end
          html = "31001-02.html"
        else
          html = "31001-01.html"
        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
