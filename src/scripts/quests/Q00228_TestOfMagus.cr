class Quests::Q00228_TestOfMagus < Quest
  # NPCs
  private PARINA = 30391
  private EARTH_SNAKE = 30409
  private FLAME_SALAMANDER = 30411
  private WIND_SYLPH = 30412
  private WATER_UNDINE = 30413
  private ELDER_CASIAN = 30612
  private BARD_RUKAL = 30629
  # Items
  private RUKALS_LETTER = 2841
  private PARINAS_LETTER = 2842
  private LILAC_CHARM = 2843
  private GOLDEN_SEED_1ST = 2844
  private GOLDEN_SEED_2ND = 2845
  private GOLDEN_SEED_3RD = 2846
  private SCORE_OF_ELEMENTS = 2847
  private DAZZLING_DROP = 2848
  private FLAME_CRYSTAL = 2849
  private HARPYS_FEATHER = 2850
  private WYRMS_WINGBONE = 2851
  private WINDSUS_MANE = 2852
  private ENCHANTED_MONSTER_EYE_SHELL = 2853
  private ENCHANTED_GOLEM_POWDER = 2854
  private ENCHANTED_IRON_GOLEM_SCRAP = 2855
  private TONE_OF_WATER = 2856
  private TONE_OF_FIRE = 2857
  private TONE_OF_WIND = 2858
  private TONE_OF_EARTH = 2859
  private SALAMANDER_CHARM = 2860
  private SYLPH_CHARM = 2861
  private UNDINE_CHARM = 2862
  private SERPENT_CHARM = 2863
  # Reward
  private MARK_OF_MAGUS = 2840
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private HARPY = 20145
  private MARSH_STAKATO = 20157
  private WYRM = 20176
  private MARSH_STAKATO_WORKER = 20230
  private TOAD_LORD = 20231
  private MARSH_STAKATO_SOLDIER = 20232
  private MARSH_STAKATO_DRONE = 20234
  private WINDSUS = 20553
  private ENCHANTED_MONSTEREYE = 20564
  private ENCHANTED_STOLEN_GOLEM = 20565
  private ENCHANTED_IRON_GOLEM = 20566
  # Quest Monster
  private SINGING_FLOWER_PHANTASM = 27095
  private SINGING_FLOWER_NIGTMATE = 27096
  private SINGING_FLOWER_DARKLING = 27097
  private GHOST_FIRE = 27098
  # Misc
  private MIN_LVL = 39

  def initialize
    super(228, self.class.simple_name, "Test Of Magus")

    add_start_npc(BARD_RUKAL)
    add_talk_id(BARD_RUKAL, PARINA, EARTH_SNAKE, FLAME_SALAMANDER, WIND_SYLPH, WATER_UNDINE, ELDER_CASIAN)
    add_kill_id(HARPY, MARSH_STAKATO, WYRM, MARSH_STAKATO_WORKER, TOAD_LORD, MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE, WINDSUS, ENCHANTED_MONSTEREYE, ENCHANTED_STOLEN_GOLEM, ENCHANTED_IRON_GOLEM, SINGING_FLOWER_PHANTASM, SINGING_FLOWER_NIGTMATE, SINGING_FLOWER_DARKLING, GHOST_FIRE)
    register_quest_items(RUKALS_LETTER, PARINAS_LETTER, LILAC_CHARM, GOLDEN_SEED_1ST, GOLDEN_SEED_2ND, GOLDEN_SEED_3RD, SCORE_OF_ELEMENTS, DAZZLING_DROP, FLAME_CRYSTAL, HARPYS_FEATHER, WYRMS_WINGBONE, WINDSUS_MANE, ENCHANTED_MONSTER_EYE_SHELL, ENCHANTED_GOLEM_POWDER, ENCHANTED_IRON_GOLEM_SCRAP, TONE_OF_WATER, TONE_OF_FIRE, TONE_OF_WIND, TONE_OF_EARTH, SALAMANDER_CHARM, SYLPH_CHARM, UNDINE_CHARM, SERPENT_CHARM)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(player, RUKALS_LETTER, 1)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(player, DIMENSIONAL_DIAMOND, 122)
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30629-04a.htm"
        else
          htmltext = "30629-04.htm"
        end
      end
    when "30629-09.html", "30409-02.html"
      htmltext = event
    when "30629-10.html"
      if has_quest_items?(player, GOLDEN_SEED_3RD)
        take_items(player, LILAC_CHARM, 1)
        take_items(player, GOLDEN_SEED_1ST, 1)
        take_items(player, GOLDEN_SEED_2ND, 1)
        take_items(player, GOLDEN_SEED_3RD, 1)
        give_items(player, SCORE_OF_ELEMENTS, 1)
        qs.set_cond(5, true)
        htmltext = event
      end
    when "30391-02.html"
      if has_quest_items?(player, RUKALS_LETTER)
        take_items(player, RUKALS_LETTER, 1)
        give_items(player, PARINAS_LETTER, 1)
        qs.set_cond(2, true)
        htmltext = event
      end
    when "30409-03.html"
      give_items(player, SERPENT_CHARM, 1)
      htmltext = event
    when "30412-02.html"
      give_items(player, SYLPH_CHARM, 1)
      htmltext = event
    when "30612-02.html"
      take_items(player, PARINAS_LETTER, 1)
      give_items(player, LILAC_CHARM, 1)
      qs.set_cond(3, true)
      htmltext = event
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when HARPY
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, SYLPH_CHARM) && (get_quest_items_count(killer, HARPYS_FEATHER) < 20)
          give_items(killer, HARPYS_FEATHER, 1)
          if get_quest_items_count(killer, HARPYS_FEATHER) >= 20
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MARSH_STAKATO, MARSH_STAKATO_WORKER, TOAD_LORD, MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, UNDINE_CHARM) && (get_quest_items_count(killer, DAZZLING_DROP) < 20)
          give_items(killer, DAZZLING_DROP, 1)
          if get_quest_items_count(killer, DAZZLING_DROP) >= 20
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when WYRM
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, SYLPH_CHARM) && (get_quest_items_count(killer, WYRMS_WINGBONE) < 10)
          if Rnd.rand(100) < 50
            give_items(killer, WYRMS_WINGBONE, 1)
            if get_quest_items_count(killer, WYRMS_WINGBONE) >= 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when WINDSUS
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, SYLPH_CHARM) && (get_quest_items_count(killer, WINDSUS_MANE) < 10)
          if Rnd.rand(100) < 50
            give_items(killer, WINDSUS_MANE, 1)
            if get_quest_items_count(killer, WINDSUS_MANE) >= 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when ENCHANTED_MONSTEREYE
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, SERPENT_CHARM) && (get_quest_items_count(killer, ENCHANTED_MONSTER_EYE_SHELL) < 10)
          give_items(killer, ENCHANTED_MONSTER_EYE_SHELL, 1)
          if get_quest_items_count(killer, ENCHANTED_MONSTER_EYE_SHELL) >= 10
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ENCHANTED_STOLEN_GOLEM
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, SERPENT_CHARM) && (get_quest_items_count(killer, ENCHANTED_GOLEM_POWDER) < 10)
          give_items(killer, ENCHANTED_GOLEM_POWDER, 1)
          if get_quest_items_count(killer, ENCHANTED_GOLEM_POWDER) >= 10
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when ENCHANTED_IRON_GOLEM
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, SERPENT_CHARM) && (get_quest_items_count(killer, ENCHANTED_IRON_GOLEM_SCRAP) < 10)
          give_items(killer, ENCHANTED_IRON_GOLEM_SCRAP, 1)
          if get_quest_items_count(killer, ENCHANTED_IRON_GOLEM_SCRAP) >= 10
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when SINGING_FLOWER_PHANTASM
        if has_quest_items?(killer, LILAC_CHARM) && !has_quest_items?(killer, GOLDEN_SEED_1ST)
          give_items(killer, GOLDEN_SEED_1ST, 1)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::I_AM_A_TREE_OF_NOTHING_A_TREE_THAT_KNOWS_WHERE_TO_RETURN))
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, GOLDEN_SEED_2ND, GOLDEN_SEED_3RD)
            qs.set_cond(4)
          end
        end
      when SINGING_FLOWER_NIGTMATE
        if has_quest_items?(killer, LILAC_CHARM) && !has_quest_items?(killer, GOLDEN_SEED_2ND)
          give_items(killer, GOLDEN_SEED_2ND, 1)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::I_AM_A_CREATURE_THAT_SHOWS_THE_TRUTH_OF_THE_PLACE_DEEP_IN_MY_HEART))
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, GOLDEN_SEED_1ST, GOLDEN_SEED_3RD)
            qs.set_cond(4)
          end
        end
      when SINGING_FLOWER_DARKLING
        if has_quest_items?(killer, LILAC_CHARM) && !has_quest_items?(killer, GOLDEN_SEED_3RD)
          give_items(killer, GOLDEN_SEED_3RD, 1)
          npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::I_AM_A_MIRROR_OF_DARKNESS_A_VIRTUAL_IMAGE_OF_DARKNESS))
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, GOLDEN_SEED_1ST, GOLDEN_SEED_2ND)
            qs.set_cond(4)
          end
        end
      when GHOST_FIRE
        if has_quest_items?(killer, SCORE_OF_ELEMENTS, SALAMANDER_CHARM) && (get_quest_items_count(killer, FLAME_CRYSTAL) < 5)
          if Rnd.rand(100) < 50
            give_items(killer, FLAME_CRYSTAL, 1)
            if get_quest_items_count(killer, FLAME_CRYSTAL) >= 5
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == BARD_RUKAL
        if player.class_id.wizard? || player.class_id.elven_wizard? || player.class_id.dark_wizard?
          if player.level < MIN_LVL
            htmltext = "30629-02.html"
          else
            htmltext = "30629-03.htm"
          end
        else
          htmltext = "30629-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when BARD_RUKAL
        if has_quest_items?(player, RUKALS_LETTER)
          htmltext = "30629-05.html"
        elsif has_quest_items?(player, PARINAS_LETTER)
          htmltext = "30629-06.html"
        elsif has_quest_items?(player, LILAC_CHARM)
          if has_quest_items?(player, GOLDEN_SEED_1ST, GOLDEN_SEED_2ND, GOLDEN_SEED_3RD)
            htmltext = "30629-08.html"
          else
            htmltext = "30629-07.html"
          end
        elsif has_quest_items?(player, SCORE_OF_ELEMENTS)
          if has_quest_items?(player, TONE_OF_WATER, TONE_OF_FIRE, TONE_OF_WIND, TONE_OF_EARTH)
            give_adena(player, 372154, true)
            give_items(player, MARK_OF_MAGUS, 1)
            add_exp_and_sp(player, 2058244, 141240)
            qs.exit_quest(false, true)
            player.send_packet(SocialAction.new(player.l2id, 3))
            htmltext = "30629-12.html"
          else
            htmltext = "30629-11.html"
          end
        end
      when PARINA
        if has_quest_items?(player, RUKALS_LETTER)
          htmltext = "30391-01.html"
        elsif has_quest_items?(player, PARINAS_LETTER)
          htmltext = "30391-03.html"
        elsif has_quest_items?(player, LILAC_CHARM)
          htmltext = "30391-04.html"
        elsif has_quest_items?(player, SCORE_OF_ELEMENTS)
          htmltext = "30391-05.html"
        end
      when EARTH_SNAKE
        if has_quest_items?(player, SCORE_OF_ELEMENTS)
          if !has_at_least_one_quest_item?(player, TONE_OF_EARTH, SERPENT_CHARM)
            htmltext = "30409-01.html"
          elsif has_quest_items?(player, SERPENT_CHARM)
            if get_quest_items_count(player, ENCHANTED_MONSTER_EYE_SHELL) >= 10 && get_quest_items_count(player, ENCHANTED_GOLEM_POWDER) >= 10 && get_quest_items_count(player, ENCHANTED_IRON_GOLEM_SCRAP) >= 10
              take_items(player, ENCHANTED_MONSTER_EYE_SHELL, -1)
              take_items(player, ENCHANTED_GOLEM_POWDER, -1)
              take_items(player, ENCHANTED_IRON_GOLEM_SCRAP, -1)
              give_items(player, TONE_OF_EARTH, 1)
              take_items(player, SERPENT_CHARM, 1)
              if has_quest_items?(player, TONE_OF_FIRE, TONE_OF_WATER, TONE_OF_WIND)
                qs.set_cond(6, true)
              end
              htmltext = "30409-05.html"
            else
              htmltext = "30409-04.html"
            end
          elsif has_quest_items?(player, TONE_OF_EARTH) && !has_quest_items?(player, SERPENT_CHARM)
            htmltext = "30409-06.html"
          end
        end
      when FLAME_SALAMANDER
        if has_quest_items?(player, SCORE_OF_ELEMENTS)
          if !has_at_least_one_quest_item?(player, TONE_OF_FIRE, SALAMANDER_CHARM)
            htmltext = "30411-01.html"
            give_items(player, SALAMANDER_CHARM, 1)
          elsif has_quest_items?(player, SALAMANDER_CHARM)
            if get_quest_items_count(player, FLAME_CRYSTAL) < 5
              htmltext = "30411-02.html"
            else
              take_items(player, FLAME_CRYSTAL, -1)
              give_items(player, TONE_OF_FIRE, 1)
              take_items(player, SALAMANDER_CHARM, 1)
              if has_quest_items?(player, TONE_OF_WATER, TONE_OF_WIND, TONE_OF_EARTH)
                qs.set_cond(6, true)
              end
              htmltext = "30411-03.html"
            end
          elsif has_quest_items?(player, TONE_OF_FIRE) && !has_quest_items?(player, SALAMANDER_CHARM)
            htmltext = "30411-04.html"
          end
        end
      when WIND_SYLPH
        if has_quest_items?(player, SCORE_OF_ELEMENTS)
          if !has_at_least_one_quest_item?(player, TONE_OF_WIND, SYLPH_CHARM)
            htmltext = "30412-01.html"
          elsif has_quest_items?(player, SYLPH_CHARM)
            if (get_quest_items_count(player, HARPYS_FEATHER) >= 20) && (get_quest_items_count(player, WYRMS_WINGBONE) >= 10) && (get_quest_items_count(player, WINDSUS_MANE) >= 10)
              take_items(player, HARPYS_FEATHER, -1)
              take_items(player, WYRMS_WINGBONE, -1)
              take_items(player, WINDSUS_MANE, -1)
              give_items(player, TONE_OF_WIND, 1)
              take_items(player, SYLPH_CHARM, 1)
              if has_quest_items?(player, TONE_OF_WATER, TONE_OF_FIRE, TONE_OF_EARTH)
                qs.set_cond(6, true)
              end
              htmltext = "30412-04.html"
            else
              htmltext = "30412-03.html"
            end
          elsif has_quest_items?(player, TONE_OF_WIND) && !has_quest_items?(player, SYLPH_CHARM)
            htmltext = "30412-05.html"
          end
        end
      when WATER_UNDINE
        if has_quest_items?(player, SCORE_OF_ELEMENTS)
          if !has_at_least_one_quest_item?(player, TONE_OF_WATER, UNDINE_CHARM)
            htmltext = "30413-01.html"
            give_items(player, UNDINE_CHARM, 1)
          elsif has_quest_items?(player, UNDINE_CHARM)
            if get_quest_items_count(player, DAZZLING_DROP) < 20
              htmltext = "30413-02.html"
            else
              take_items(player, DAZZLING_DROP, -1)
              give_items(player, TONE_OF_WATER, 1)
              take_items(player, UNDINE_CHARM, 1)
              if has_quest_items?(player, TONE_OF_FIRE, TONE_OF_WIND, TONE_OF_EARTH)
                qs.set_cond(6, true)
              end
              htmltext = "30413-03.html"
            end
          elsif has_quest_items?(player, TONE_OF_WATER) && !has_quest_items?(player, UNDINE_CHARM)
            htmltext = "30413-04.html"
          end
        end
      when ELDER_CASIAN
        if has_quest_items?(player, PARINAS_LETTER)
          htmltext = "30612-01.html"
        elsif has_quest_items?(player, LILAC_CHARM)
          if has_quest_items?(player, GOLDEN_SEED_1ST, GOLDEN_SEED_2ND, GOLDEN_SEED_3RD)
            htmltext = "30612-04.html"
          else
            htmltext = "30612-03.html"
          end
        elsif has_quest_items?(player, SCORE_OF_ELEMENTS)
          htmltext = "30612-05.html"
        end
      end
    elsif qs.completed?
      if npc.id == BARD_RUKAL
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
