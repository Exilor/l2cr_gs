class Scripts::Q00225_TestOfTheSearcher < Quest
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
    add_talk_id(
      MASTER_LUTHER, CAPTAIN_ALEX, TYRA, TREE, STRONG_WOODEN_CHEST,
      MILITIAMAN_LEIRYNN, DRUNKARD_BORYS, BODYGUARD_JAX
    )
    add_kill_id(
      HANGMAN_TREE, ROAD_SCAVENGER, GIANT_FUNGUS, DELU_LIZARDMAN_SHAMAN,
      NEER_BODYGUARD, DELU_CHIEF_KALKIS
    )
    add_attack_id(DELU_LIZARDMAN_SHAMAN)
    register_quest_items(
      LUTHERS_LETTER, ALEXS_WARRANT, LEIRYNNS_1ST_ORDER, DELU_TOTEM,
      LEIRYNNS_2ND_ORDER, CHIEF_KALKIS_FANG, LEIRYNNS_REPORT, STRINGE_MAP,
      LAMBERTS_MAP, ALEXS_LETTER, ALEXS_ORDER, WINE_CATALOG, TYRAS_CONTRACT,
      RED_SPORE_DUST, MALRUKIAN_WINE, OLD_ORDER, JAXS_DIARY, TORN_MAP_PIECE_1ST,
      TORN_MAP_PIECE_2ND, SOLTS_MAP, MAKELS_MAP, COMBINED_MAP, RUSTED_KEY,
      GOLD_BAR, ALEXS_RECOMMEND
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        give_items(pc, LUTHERS_LETTER, 1)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          if pc.class_id.scavenger?
            give_items(pc, DIMENSIONAL_DIAMOND, 82)
          else
            give_items(pc, DIMENSIONAL_DIAMOND, 96)
          end
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30690-05a.htm"
        else
          html = "30690-05.htm"
        end
      end
    when "30291-05.html", "30291-01t.html", "30291-06.html", "30730-01a.html",
         "30730-01b.html", "30730-01c.html", "30730-02.html", "30730-02a.html",
         "30730-02b.html"
      html = event
    when "30291-07.html"
      if has_quest_items?(pc, LEIRYNNS_REPORT, STRINGE_MAP)
        take_items(pc, LEIRYNNS_REPORT, 1)
        take_items(pc, STRINGE_MAP, 1)
        give_items(pc, LAMBERTS_MAP, 1)
        give_items(pc, ALEXS_LETTER, 1)
        give_items(pc, ALEXS_ORDER, 1)
        qs.set_cond(8, true)
        html = event
      end
    when "30420-01a.html"
      if has_quest_items?(pc, WINE_CATALOG)
        take_items(pc, WINE_CATALOG, 1)
        give_items(pc, TYRAS_CONTRACT, 1)
        qs.set_cond(10, true)
        html = event
      end
    when "30627-01a.html"
      npc = npc.not_nil!
      if npc.summoned_npc_count < 5
        give_items(pc, RUSTED_KEY, 1)
        add_spawn(npc, STRONG_WOODEN_CHEST, npc, true, 0)
        qs.set_cond(17, true)
        html = event
      end
    when "30628-01a.html"
      npc = npc.not_nil!
      take_items(pc, RUSTED_KEY, 1)
      give_items(pc, GOLD_BAR, 20)
      qs.set_cond(18, true)
      npc.delete_me
      html = event
    when "30730-01d.html"
      if has_quest_items?(pc, OLD_ORDER)
        take_items(pc, OLD_ORDER, 1)
        give_items(pc, JAXS_DIARY, 1)
        qs.set_cond(14, true)
        html = event
      end
    end

    html
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

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == MASTER_LUTHER
        class_id = pc.class_id
        if class_id.rogue? || class_id.elven_scout? || class_id.assassin? || class_id.scavenger?
          if pc.level >= MIN_LEVEL
            if class_id.scavenger?
              html = "30690-04.htm"
            else
              html = "30690-03.htm"
            end
          else
            html = "30690-02.html"
          end
        else
          html = "30690-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_LUTHER
        if has_quest_items?(pc, LUTHERS_LETTER) && !has_quest_items?(pc, ALEXS_RECOMMEND)
          html = "30690-06.html"
        elsif !has_at_least_one_quest_item?(pc, LUTHERS_LETTER, ALEXS_RECOMMEND)
          html = "30690-07.html"
        elsif !has_quest_items?(pc, LUTHERS_LETTER) && has_quest_items?(pc, ALEXS_RECOMMEND)
          give_adena(pc, 161806, true)
          give_items(pc, MARK_OF_SEARCHER, 1)
          add_exp_and_sp(pc, 894888, 61408)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = "30690-08.html"
        end
      when CAPTAIN_ALEX
        if has_quest_items?(pc, LUTHERS_LETTER)
          take_items(pc, LUTHERS_LETTER, 1)
          give_items(pc, ALEXS_WARRANT, 1)
          qs.set_cond(2, true)
          html = "30291-01.html"
        elsif has_quest_items?(pc, ALEXS_WARRANT)
          html = "30291-02.html"
        elsif has_at_least_one_quest_item?(pc, LEIRYNNS_1ST_ORDER, LEIRYNNS_2ND_ORDER)
          html = "30291-03.html"
        elsif has_quest_items?(pc, LEIRYNNS_REPORT)
          html = "30291-04.html"
        elsif has_quest_items?(pc, ALEXS_ORDER)
          if has_quest_items?(pc, ALEXS_LETTER)
            html = "30291-08.html"
          elsif has_at_least_one_quest_item?(pc, OLD_ORDER, JAXS_DIARY)
            html = "30291-09.html"
          elsif has_quest_items?(pc, COMBINED_MAP)
            if get_quest_items_count(pc, GOLD_BAR) == 20
              take_items(pc, ALEXS_ORDER, 1)
              take_items(pc, COMBINED_MAP, 1)
              take_items(pc, GOLD_BAR, -1)
              give_items(pc, ALEXS_RECOMMEND, 1)
              pc.radar.remove_marker(10133, 157155, -2383)
              qs.set_cond(19, true)
              html = "30291-11.html"
            else
              html = "30291-10.html"
            end
          end
        elsif has_quest_items?(pc, ALEXS_RECOMMEND)
          html = "30291-12.html"
        end
      when TYRA
        if has_quest_items?(pc, WINE_CATALOG)
          html = "30420-01.html"
        elsif has_quest_items?(pc, TYRAS_CONTRACT)
          if get_quest_items_count(pc, RED_SPORE_DUST) < 10
            html = "30420-02.html"
          else
            take_items(pc, TYRAS_CONTRACT, 1)
            take_items(pc, RED_SPORE_DUST, -1)
            give_items(pc, MALRUKIAN_WINE, 1)
            qs.set_cond(12, true)
            html = "30420-03.html"
          end
        elsif has_at_least_one_quest_item?(pc, JAXS_DIARY, OLD_ORDER, COMBINED_MAP, ALEXS_RECOMMEND, MALRUKIAN_WINE)
          html = "30420-04.html"
        end
      when TREE
        if has_quest_items?(pc, COMBINED_MAP)
          if !has_at_least_one_quest_item?(pc, RUSTED_KEY, GOLD_BAR)
            html = "30627-01.html"
          elsif has_quest_items?(pc, RUSTED_KEY) && get_quest_items_count(pc, GOLD_BAR) >= 20
            html = "30627-01.html"
          end
        end
      when STRONG_WOODEN_CHEST
        if has_quest_items?(pc, RUSTED_KEY)
          html = "30628-01.html"
        end
      when MILITIAMAN_LEIRYNN
        if has_quest_items?(pc, ALEXS_WARRANT)
          take_items(pc, ALEXS_WARRANT, 1)
          give_items(pc, LEIRYNNS_1ST_ORDER, 1)
          qs.set_cond(3, true)
          html = "30728-01.html"
        elsif has_quest_items?(pc, LEIRYNNS_1ST_ORDER)
          if get_quest_items_count(pc, DELU_TOTEM) < 10
            html = "30728-02.html"
          else
            take_items(pc, LEIRYNNS_1ST_ORDER, 1)
            take_items(pc, DELU_TOTEM, -1)
            give_items(pc, LEIRYNNS_2ND_ORDER, 1)
            qs.set_cond(5, true)
            html = "30728-03.html"
          end
        elsif has_quest_items?(pc, LEIRYNNS_2ND_ORDER)
          if !has_quest_items?(pc, CHIEF_KALKIS_FANG)
            html = "30728-04.html"
          else
            take_items(pc, LEIRYNNS_2ND_ORDER, 1)
            take_items(pc, CHIEF_KALKIS_FANG, 1)
            give_items(pc, LEIRYNNS_REPORT, 1)
            qs.set_cond(7, true)
            html = "30728-05.html"
          end
        elsif has_quest_items?(pc, LEIRYNNS_REPORT)
          html = "30728-06.html"
        elsif has_at_least_one_quest_item?(pc, ALEXS_RECOMMEND, ALEXS_ORDER)
          html = "30728-07.html"
        end
      when DRUNKARD_BORYS
        if has_quest_items?(pc, ALEXS_LETTER)
          take_items(pc, ALEXS_LETTER, 1)
          give_items(pc, WINE_CATALOG, 1)
          qs.set_cond(9, true)
          html = "30729-01.html"
        elsif has_quest_items?(pc, WINE_CATALOG) && !has_quest_items?(pc, MALRUKIAN_WINE)
          html = "30729-02.html"
        elsif has_quest_items?(pc, MALRUKIAN_WINE) && !has_quest_items?(pc, WINE_CATALOG)
          take_items(pc, MALRUKIAN_WINE, 1)
          give_items(pc, OLD_ORDER, 1)
          qs.set_cond(13, true)
          html = "30729-03.html"
        elsif has_quest_items?(pc, OLD_ORDER)
          html = "30729-04.html"
        elsif has_at_least_one_quest_item?(pc, JAXS_DIARY, COMBINED_MAP, ALEXS_RECOMMEND)
          html = "30729-05.html"
        end
      when BODYGUARD_JAX
        if has_quest_items?(pc, OLD_ORDER)
          html = "30730-01.html"
        elsif has_quest_items?(pc, JAXS_DIARY)
          if get_quest_items_count(pc, SOLTS_MAP) + get_quest_items_count(pc, MAKELS_MAP) < 2
            html = "30730-02.html"
          elsif get_quest_items_count(pc, SOLTS_MAP) + get_quest_items_count(pc, MAKELS_MAP) == 2
            take_items(pc, LAMBERTS_MAP, 1)
            take_items(pc, JAXS_DIARY, 1)
            take_items(pc, SOLTS_MAP, 1)
            take_items(pc, MAKELS_MAP, -1)
            give_items(pc, COMBINED_MAP, 1)
            qs.set_cond(16, true)
            html = "30730-03.html"
          end
        elsif has_at_least_one_quest_item?(pc, COMBINED_MAP, ALEXS_RECOMMEND)
          html = "30730-04.html"
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_LUTHER
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
