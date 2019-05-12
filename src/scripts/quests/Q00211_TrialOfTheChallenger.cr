class Scripts::Q00211_TrialOfTheChallenger < Quest
  # NPCs
  private FILAUR = 30535
  private KASH = 30644
  private MARTIAN = 30645
  private RALDO = 30646
  private CHEST_OF_SHYSLASSYS = 30647
  private MARKETEER_OF_MAMMON = 31092
  # Items
  private LETTER_OF_KASH = 2628
  private WATCHERS_EYE1 = 2629
  private WATCHERS_EYE2 = 2630
  private SCROLL_OF_SHYSLASSYS = 2631
  private BROKEN_KEY = 2632
  # Monsters
  private SHYSLASSYS = 27110
  private GORR = 27112
  private BARAHAM = 27113
  private QUEEN_OF_SUCCUBUS = 27114
  # Rewards
  private ELVEN_NECKLACE_BEADS = 1904
  private WHITE_TUNIC_PATTERN = 1936
  private IRON_BOOTS_DESIGN = 1940
  private MANTICOR_SKIN_GAITERS_PATTERN = 1943
  private GAUNTLET_OF_REPOSE_PATTERN = 1946
  private MITHRIL_SCALE_GAITERS_MATERIAL = 2918
  private BRIGAMDINE_GAUNTLET_PATTERN = 2927
  private TOME_OF_BLOOD_PAGE = 2030
  private MARK_OF_CHALLENGER = 2627
  private DIMENSIONAL_DIAMONDS = ItemHolder.new(7562, 61)
  # Misc
  private MIN_LVL = 35

  def initialize
    super(211, self.class.simple_name, "Trial of the Challenger")

    add_start_npc(KASH)
    add_talk_id(
      FILAUR, KASH, MARTIAN, RALDO, CHEST_OF_SHYSLASSYS, MARKETEER_OF_MAMMON
    )
    add_kill_id(SHYSLASSYS, GORR, BARAHAM, QUEEN_OF_SUCCUBUS)
    register_quest_items(
      LETTER_OF_KASH, WATCHERS_EYE1, WATCHERS_EYE2, SCROLL_OF_SHYSLASSYS,
      BROKEN_KEY
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "30644-04.htm"
      html = event
    when "30645-07.html", "30645-08.html", "30646-02.html", "30646-03.html"
      if qs.started?
        html = event
      end
    when "30644-06.htm"
      if qs.created?
        vars = pc.variables
        if vars.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMONDS)
          vars["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = event
        else
          html = "30644-05.htm"
        end
        qs.start_quest
      end
    when "30647-02.html"
      if qs.cond?(2) && has_quest_items?(pc, BROKEN_KEY)
        take_items(pc, BROKEN_KEY, -1)
        if Rnd.rand(10) < 2
          play_sound(pc, Sound::ITEMSOUND_QUEST_JACKPOT)
          random = Rnd.rand(100)
          if random > 90
            reward_items(pc, MITHRIL_SCALE_GAITERS_MATERIAL, 1)
            reward_items(pc, BRIGAMDINE_GAUNTLET_PATTERN, 1)
            reward_items(pc, MANTICOR_SKIN_GAITERS_PATTERN, 1)
            reward_items(pc, GAUNTLET_OF_REPOSE_PATTERN, 1)
            reward_items(pc, IRON_BOOTS_DESIGN, 1)
          elsif random > 70
            reward_items(pc, TOME_OF_BLOOD_PAGE, 1)
            reward_items(pc, ELVEN_NECKLACE_BEADS, 1)
          elsif random > 40
            reward_items(pc, WHITE_TUNIC_PATTERN, 1)
          else
            reward_items(pc, IRON_BOOTS_DESIGN, 1)
          end
          html = "30647-03.html"
        else
          give_adena(pc, Rnd.rand(1000i64) + 1, true)
          html = event
        end
      else
        html = "30647-04.html"
      end
    when "30645-02.html"
      if qs.cond?(3) && has_quest_items?(pc, LETTER_OF_KASH)
        qs.set_cond(4, true)
        html = event
      end
    when "30646-04.html", "30646-05.html"
      if qs.cond?(7) && has_quest_items?(pc, WATCHERS_EYE2)
        take_items(pc, WATCHERS_EYE2, -1)
        qs.set_cond(8, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when KASH
      if qs.created?
        if !pc.in_category?(CategoryType::WARRIOR_GROUP)
          html = "30644-02.html"
        elsif pc.level < MIN_LVL
          html = "30644-01.html"
        else
          html = "30644-03.htm"
        end
      elsif qs.started?
          case qs.cond
          when 1
            html = "30644-07.html"
          when 2
            if has_quest_items?(pc, SCROLL_OF_SHYSLASSYS)
              take_items(pc, SCROLL_OF_SHYSLASSYS, -1)
              give_items(pc, LETTER_OF_KASH, 1)
              qs.set_cond(3, true)
              html = "30644-08.html"
            end
          when 3
            if has_quest_items?(pc, LETTER_OF_KASH)
              html = "30644-09.html"
            end
          when 8..10
            html = "30644-10.html"
          end
        elsif qs.completed?
          html = get_already_completed_msg(pc)
        end
    when MARTIAN
      case qs.cond
      when 3
        if has_quest_items?(pc, LETTER_OF_KASH)
          html = "30645-01.html"
        end
      when 4
        html = "30645-03.html"
      when 5
        if has_quest_items?(pc, WATCHERS_EYE1)
          take_items(pc, WATCHERS_EYE1, -1)
          qs.set_cond(6, true)
          html = "30645-04.html"
        end
      when 6
        html = "30645-05.html"
      when 7
        html = "30645-06.html"
      when 8, 9
        html = "30645-09.html"
      end
    when CHEST_OF_SHYSLASSYS
      if qs.started?
        html = "30647-01.html"
      end
    when RALDO
      case qs.cond
      when 7
        if has_quest_items?(pc, WATCHERS_EYE2)
          html = "30646-01.html"
        end
      when 8
        html = "30646-06.html"
      when 10
        add_exp_and_sp(pc, 1067606, 69242)
        give_adena(pc, 194556, true)
        give_items(pc, MARK_OF_CHALLENGER, 1)

        # redundant retail check - already rewarded at beginning of quest
        vars = pc.variables
        if vars.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMONDS)
          vars["2ND_CLASS_DIAMOND_REWARD"] = 1
        end

        pc.send_packet(SocialAction.new(pc.l2id, 3))
        qs.exit_quest(false, true)
        html = "30646-07.html"
      end
    when FILAUR
      case qs.cond
      when 8
        html = "30535-01.html"
        qs.set_cond(9, true)
      when 9
        pc.send_packet(RadarControl.new(0, 2, 151589, -174823, -1776))
        html = "30535-02.html"
      when 10
        html = "30535-03.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    return super unless qs = get_quest_state(killer, false)
    unless Util.in_range?(1500, npc, killer, true)
      return super
    end

    case npc.id
    when SHYSLASSYS
      if qs.cond?(1)
        if SpawnTable.get_spawns(npc.id).size < 10
          add_spawn(CHEST_OF_SHYSLASSYS, npc, false, 200000)
        end
        give_items(killer, SCROLL_OF_SHYSLASSYS, 1)
        give_items(killer, BROKEN_KEY, 1)
        qs.set_cond(2, true)
      end
    when GORR
      if qs.cond?(4)
        give_items(killer, WATCHERS_EYE1, 1)
        qs.set_cond(5, true)
      end
    when BARAHAM
      if qs.cond?(6)
        if SpawnTable.get_spawns(npc.id).size < 10
          add_spawn(RALDO, npc, false, 100000)
        end
        give_items(killer, WATCHERS_EYE2, 1)
        qs.set_cond(7, true)
      end
    when QUEEN_OF_SUCCUBUS
      if qs.cond?(9)
        if SpawnTable.get_spawns(npc.id).size < 10
          add_spawn(RALDO, npc, false, 100000)
        end
        qs.set_cond(10, true)
      end
    end

    super
  end
end
