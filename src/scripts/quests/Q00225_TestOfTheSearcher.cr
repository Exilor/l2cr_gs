class Quests::Q00225_TestOfTheSearcher < Quest
  # NPCs
  private CAPTAIN_ALEX = 30291
  private TYRA = 30420
  private TREE = 30627
  private STRONG_WOODEN_CHEST = 30628
  private MASTER_LUTHER = 30690
  private MILITIAMAN_LEIRYNN = 30728
  private DRUNKARD_BORYS = 30729
  private BODYGUARD_JAX = 30730
  # Items
  private LUTHERS_LETTER = 2784
  private ALEXS_WARRANT = 2785
  private LEIRYNNS_1ST_ORDER = 2786
  private DELU_TOTEM = 2787
  private LEIRYNNS_2ND_ORDER = 2788
  private CHIEF_KALKIS_FANG = 2789
  private LEIRYNNS_REPORT = 2790
  private STRINGE_MAP = 2791
  private LAMBERTS_MAP = 2792
  private ALEXS_LETTER = 2793
  private ALEXS_ORDER = 2794
  private WINE_CATALOG = 2795
  private TYRAS_CONTRACT = 2796
  private RED_SPORE_DUST = 2797
  private MALRUKIAN_WINE = 2798
  private OLD_ORDER = 2799
  private JAXS_DIARY = 2800
  private TORN_MAP_PIECE_1ST = 2801
  private TORN_MAP_PIECE_2ND = 2802
  private SOLTS_MAP = 2803
  private MAKELS_MAP = 2804
  private COMBINED_MAP = 2805
  private RUSTED_KEY = 2806
  private GOLD_BAR = 2807
  private ALEXS_RECOMMEND = 2808
  # Reward
  private MARK_OF_SEARCHER = 2809
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private HANGMAN_TREE = 20144
  private ROAD_SCAVENGER = 20551
  private GIANT_FUNGUS = 20555
  private DELU_LIZARDMAN_SHAMAN = 20781
  # Quest Monster
  private NEER_BODYGUARD = 27092
  private DELU_CHIEF_KALKIS = 27093
  # Misc
  private MIN_LEVEL = 39

  def initialize
    super(225, self.class.simple_name, "Test Of The Searcher")

    add_start_npc(MASTER_LUTHER)
    add_talk_id(MASTER_LUTHER, CAPTAIN_ALEX, TYRA, TREE, STRONG_WOODEN_CHEST, MILITIAMAN_LEIRYNN, DRUNKARD_BORYS, BODYGUARD_JAX)
    add_kill_id(HANGMAN_TREE, ROAD_SCAVENGER, GIANT_FUNGUS, DELU_LIZARDMAN_SHAMAN, NEER_BODYGUARD, DELU_CHIEF_KALKIS)
    add_attack_id(DELU_LIZARDMAN_SHAMAN)
    register_quest_items(LUTHERS_LETTER, ALEXS_WARRANT, LEIRYNNS_1ST_ORDER, DELU_TOTEM, LEIRYNNS_2ND_ORDER, CHIEF_KALKIS_FANG, LEIRYNNS_REPORT, STRINGE_MAP, LAMBERTS_MAP, ALEXS_LETTER, ALEXS_ORDER, WINE_CATALOG, TYRAS_CONTRACT, RED_SPORE_DUST, MALRUKIAN_WINE, OLD_ORDER, JAXS_DIARY, TORN_MAP_PIECE_1ST, TORN_MAP_PIECE_2ND, SOLTS_MAP, MAKELS_MAP, COMBINED_MAP, RUSTED_KEY, GOLD_BAR, ALEXS_RECOMMEND)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(player, LUTHERS_LETTER, 1)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          if player.class_id.scavenger?
            give_items(player, DIMENSIONAL_DIAMOND, 82)
          else
            give_items(player, DIMENSIONAL_DIAMOND, 96)
          end
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30690-05a.htm"
        else
          htmltext = "30690-05.htm"
        end
      end
    when "30291-05.html", "30291-01t.html", "30291-06.html", "30730-01a.html",
         "30730-01b.html", "30730-01c.html", "30730-02.html", "30730-02a.html",
         "30730-02b.html"
      htmltext = event
    when "30291-07.html"
      if has_quest_items?(player, LEIRYNNS_REPORT, STRINGE_MAP)
        take_items(player, LEIRYNNS_REPORT, 1)
        take_items(player, STRINGE_MAP, 1)
        give_items(player, LAMBERTS_MAP, 1)
        give_items(player, ALEXS_LETTER, 1)
        give_items(player, ALEXS_ORDER, 1)
        qs.set_cond(8, true)
        htmltext = event
      end
    when "30420-01a.html"
      if has_quest_items?(player, WINE_CATALOG)
        take_items(player, WINE_CATALOG, 1)
        give_items(player, TYRAS_CONTRACT, 1)
        qs.set_cond(10, true)
        htmltext = event
      end
    when "30627-01a.html"
      npc = npc.not_nil!
      if npc.summoned_npc_count < 5
        give_items(player, RUSTED_KEY, 1)
        add_spawn(npc, STRONG_WOODEN_CHEST, npc, true, 0)
        qs.set_cond(17, true)
        htmltext = event
      end
    when "30628-01a.html"
      npc = npc.not_nil!
      take_items(player, RUSTED_KEY, 1)
      give_items(player, GOLD_BAR, 20)
      qs.set_cond(18, true)
      npc.delete_me
      htmltext = event
    when "30730-01d.html"
      if has_quest_items?(player, OLD_ORDER)
        take_items(player, OLD_ORDER, 1)
        give_items(player, JAXS_DIARY, 1)
        qs.set_cond(14, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_attack(npc, attacker, damage, is_summon)
    qs = get_quest_state(attacker, false)
    if qs && qs.started?
      if npc.script_value?(0) && has_quest_items?(attacker, LEIRYNNS_1ST_ORDER)
        npc.script_value = 1
        add_attack_desire(add_spawn(NEER_BODYGUARD, npc, true, 200000), attacker)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when HANGMAN_TREE
        if has_quest_items?(killer, JAXS_DIARY) && !has_quest_items?(killer, MAKELS_MAP) && (get_quest_items_count(killer, TORN_MAP_PIECE_2ND) < 4)
          if get_quest_items_count(killer, TORN_MAP_PIECE_2ND) < 3
            if Rnd.rand(100) < 50
              give_items(killer, TORN_MAP_PIECE_2ND, 1)
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          elsif Rnd.rand(100) < 50
            take_items(killer, TORN_MAP_PIECE_2ND, -1)
            give_items(killer, MAKELS_MAP, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, SOLTS_MAP) >= 1
              qs.set_cond(15)
            end
          end
        end
      when ROAD_SCAVENGER
        if has_quest_items?(killer, JAXS_DIARY) && !has_quest_items?(killer, SOLTS_MAP) && (get_quest_items_count(killer, TORN_MAP_PIECE_1ST) < 4)
          if get_quest_items_count(killer, TORN_MAP_PIECE_1ST) < 3
            give_items(killer, TORN_MAP_PIECE_1ST, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          else
            take_items(killer, TORN_MAP_PIECE_1ST, -1)
            give_items(killer, SOLTS_MAP, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            if get_quest_items_count(killer, MAKELS_MAP) >= 1
              qs.set_cond(15)
            end
          end
        end
      when GIANT_FUNGUS
        if has_quest_items?(killer, TYRAS_CONTRACT) && get_quest_items_count(killer, RED_SPORE_DUST) < 10
          give_items(killer, RED_SPORE_DUST, 1)
          if get_quest_items_count(killer, RED_SPORE_DUST) >= 10
            qs.set_cond(11, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when DELU_LIZARDMAN_SHAMAN
        if has_quest_items?(killer, LEIRYNNS_1ST_ORDER) && get_quest_items_count(killer, DELU_TOTEM) < 10
          give_items(killer, DELU_TOTEM, 1)
          if get_quest_items_count(killer, RED_SPORE_DUST) >= 10
            qs.set_cond(4, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when DELU_CHIEF_KALKIS
        if has_quest_items?(killer, LEIRYNNS_2ND_ORDER) && !has_at_least_one_quest_item?(killer, CHIEF_KALKIS_FANG, STRINGE_MAP)
          give_items(killer, CHIEF_KALKIS_FANG, 1)
          give_items(killer, STRINGE_MAP, 1)
          qs.set_cond(6, true)
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == MASTER_LUTHER
        class_id = player.class_id
        if class_id.rogue? || class_id.elven_scout? || class_id.assassin? || class_id.scavenger?
          if player.level >= MIN_LEVEL
            if class_id.scavenger?
              htmltext = "30690-04.htm"
            else
              htmltext = "30690-03.htm"
            end
          else
            htmltext = "30690-02.html"
          end
        else
          htmltext = "30690-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_LUTHER
        if has_quest_items?(player, LUTHERS_LETTER) && !has_quest_items?(player, ALEXS_RECOMMEND)
          htmltext = "30690-06.html"
        elsif !has_at_least_one_quest_item?(player, LUTHERS_LETTER, ALEXS_RECOMMEND)
          htmltext = "30690-07.html"
        elsif !has_quest_items?(player, LUTHERS_LETTER) && has_quest_items?(player, ALEXS_RECOMMEND)
          give_adena(player, 161806, true)
          give_items(player, MARK_OF_SEARCHER, 1)
          add_exp_and_sp(player, 894888, 61408)
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          htmltext = "30690-08.html"
        end
      when CAPTAIN_ALEX
        if has_quest_items?(player, LUTHERS_LETTER)
          take_items(player, LUTHERS_LETTER, 1)
          give_items(player, ALEXS_WARRANT, 1)
          qs.set_cond(2, true)
          htmltext = "30291-01.html"
        elsif has_quest_items?(player, ALEXS_WARRANT)
          htmltext = "30291-02.html"
        elsif has_at_least_one_quest_item?(player, LEIRYNNS_1ST_ORDER, LEIRYNNS_2ND_ORDER)
          htmltext = "30291-03.html"
        elsif has_quest_items?(player, LEIRYNNS_REPORT)
          htmltext = "30291-04.html"
        elsif has_quest_items?(player, ALEXS_ORDER)
          if has_quest_items?(player, ALEXS_LETTER)
            htmltext = "30291-08.html"
          elsif has_at_least_one_quest_item?(player, OLD_ORDER, JAXS_DIARY)
            htmltext = "30291-09.html"
          elsif has_quest_items?(player, COMBINED_MAP)
            if get_quest_items_count(player, GOLD_BAR) == 20
              take_items(player, ALEXS_ORDER, 1)
              take_items(player, COMBINED_MAP, 1)
              take_items(player, GOLD_BAR, -1)
              give_items(player, ALEXS_RECOMMEND, 1)
              player.radar.remove_marker(10133, 157155, -2383)
              qs.set_cond(19, true)
              htmltext = "30291-11.html"
            else
              htmltext = "30291-10.html"
            end
          end
        elsif has_quest_items?(player, ALEXS_RECOMMEND)
          htmltext = "30291-12.html"
        end
      when TYRA
        if has_quest_items?(player, WINE_CATALOG)
          htmltext = "30420-01.html"
        elsif has_quest_items?(player, TYRAS_CONTRACT)
          if get_quest_items_count(player, RED_SPORE_DUST) < 10
            htmltext = "30420-02.html"
          else
            take_items(player, TYRAS_CONTRACT, 1)
            take_items(player, RED_SPORE_DUST, -1)
            give_items(player, MALRUKIAN_WINE, 1)
            qs.set_cond(12, true)
            htmltext = "30420-03.html"
          end
        elsif has_at_least_one_quest_item?(player, JAXS_DIARY, OLD_ORDER, COMBINED_MAP, ALEXS_RECOMMEND, MALRUKIAN_WINE)
          htmltext = "30420-04.html"
        end
      when TREE
        if has_quest_items?(player, COMBINED_MAP)
          if !has_at_least_one_quest_item?(player, RUSTED_KEY, GOLD_BAR)
            htmltext = "30627-01.html"
          elsif has_quest_items?(player, RUSTED_KEY) && get_quest_items_count(player, GOLD_BAR) >= 20
            htmltext = "30627-01.html"
          end
        end
      when STRONG_WOODEN_CHEST
        if has_quest_items?(player, RUSTED_KEY)
          htmltext = "30628-01.html"
        end
      when MILITIAMAN_LEIRYNN
        if has_quest_items?(player, ALEXS_WARRANT)
          take_items(player, ALEXS_WARRANT, 1)
          give_items(player, LEIRYNNS_1ST_ORDER, 1)
          qs.set_cond(3, true)
          htmltext = "30728-01.html"
        elsif has_quest_items?(player, LEIRYNNS_1ST_ORDER)
          if get_quest_items_count(player, DELU_TOTEM) < 10
            htmltext = "30728-02.html"
          else
            take_items(player, LEIRYNNS_1ST_ORDER, 1)
            take_items(player, DELU_TOTEM, -1)
            give_items(player, LEIRYNNS_2ND_ORDER, 1)
            qs.set_cond(5, true)
            htmltext = "30728-03.html"
          end
        elsif has_quest_items?(player, LEIRYNNS_2ND_ORDER)
          if !has_quest_items?(player, CHIEF_KALKIS_FANG)
            htmltext = "30728-04.html"
          else
            take_items(player, LEIRYNNS_2ND_ORDER, 1)
            take_items(player, CHIEF_KALKIS_FANG, 1)
            give_items(player, LEIRYNNS_REPORT, 1)
            qs.set_cond(7, true)
            htmltext = "30728-05.html"
          end
        elsif has_quest_items?(player, LEIRYNNS_REPORT)
          htmltext = "30728-06.html"
        elsif has_at_least_one_quest_item?(player, ALEXS_RECOMMEND, ALEXS_ORDER)
          htmltext = "30728-07.html"
        end
      when DRUNKARD_BORYS
        if has_quest_items?(player, ALEXS_LETTER)
          take_items(player, ALEXS_LETTER, 1)
          give_items(player, WINE_CATALOG, 1)
          qs.set_cond(9, true)
          htmltext = "30729-01.html"
        elsif has_quest_items?(player, WINE_CATALOG) && !has_quest_items?(player, MALRUKIAN_WINE)
          htmltext = "30729-02.html"
        elsif has_quest_items?(player, MALRUKIAN_WINE) && !has_quest_items?(player, WINE_CATALOG)
          take_items(player, MALRUKIAN_WINE, 1)
          give_items(player, OLD_ORDER, 1)
          qs.set_cond(13, true)
          htmltext = "30729-03.html"
        elsif has_quest_items?(player, OLD_ORDER)
          htmltext = "30729-04.html"
        elsif has_at_least_one_quest_item?(player, JAXS_DIARY, COMBINED_MAP, ALEXS_RECOMMEND)
          htmltext = "30729-05.html"
        end
      when BODYGUARD_JAX
        if has_quest_items?(player, OLD_ORDER)
          htmltext = "30730-01.html"
        elsif has_quest_items?(player, JAXS_DIARY)
          if get_quest_items_count(player, SOLTS_MAP) + get_quest_items_count(player, MAKELS_MAP) < 2
            htmltext = "30730-02.html"
          elsif get_quest_items_count(player, SOLTS_MAP) + get_quest_items_count(player, MAKELS_MAP) == 2
            take_items(player, LAMBERTS_MAP, 1)
            take_items(player, JAXS_DIARY, 1)
            take_items(player, SOLTS_MAP, 1)
            take_items(player, MAKELS_MAP, -1)
            give_items(player, COMBINED_MAP, 1)
            qs.set_cond(16, true)
            htmltext = "30730-03.html"
          end
        elsif has_at_least_one_quest_item?(player, COMBINED_MAP, ALEXS_RECOMMEND)
          htmltext = "30730-04.html"
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_LUTHER
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
