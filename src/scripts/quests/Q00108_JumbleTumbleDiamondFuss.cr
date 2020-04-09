class Scripts::Q00108_JumbleTumbleDiamondFuss < Quest
  # NPCs
  private COLLECTOR_GOUPH = 30523
  private TRADER_REEP = 30516
  private CARRIER_TOROCCO = 30555
  private MINER_MARON = 30529
  private BLACKSMITH_BRUNON = 30526
  private WAREHOUSE_KEEPER_MURDOC = 30521
  private WAREHOUSE_KEEPER_AIRY = 30522
  # Monsters
  private GOBLIN_BRIGAND_LEADER = 20323
  private GOBLIN_BRIGAND_LIEUTENANT = 20324
  private BLADE_BAT = 20480
  # Items
  private GOUPHS_CONTRACT = 1559
  private REEPS_CONTRACT = 1560
  private ELVEN_WINE = 1561
  private BRUNONS_DICE = 1562
  private BRUNONS_CONTRACT = 1563
  private AQUAMARINE = 1564
  private CHRYSOBERYL = 1565
  private GEM_BOX = 1566
  private COAL_PIECE = 1567
  private BRUNONS_LETTER = 1568
  private BERRY_TART = 1569
  private BAT_DIAGRAM = 1570
  private STAR_DIAMOND = 1571
  # Rewards
  private REWARDS = {
    ItemHolder.new(1060, 100), # Lesser Healing Potion
    ItemHolder.new(4412, 10),  # Echo Crystal - Theme of Battle
    ItemHolder.new(4413, 10),  # Echo Crystal - Theme of Love
    ItemHolder.new(4414, 10),  # Echo Crystal - Theme of Solitude
    ItemHolder.new(4415, 10),  # Echo Crystal - Theme of Feast
    ItemHolder.new(4416, 10)   # Echo Crystal - Theme of Celebration
  }
  private SILVERSMITH_HAMMER = 1511
  # Misc
  private MIN_LVL = 10
  private MAX_GEM_COUNT = 10
  private GOBLIN_DROP_CHANCES = {
    GOBLIN_BRIGAND_LEADER => 0.8,
    GOBLIN_BRIGAND_LIEUTENANT => 0.6
  }

  def initialize
    super(108, self.class.simple_name, "Jumble, Tumble, Diamond Fuss")

    add_start_npc(COLLECTOR_GOUPH)
    add_talk_id(
      COLLECTOR_GOUPH, TRADER_REEP, CARRIER_TOROCCO, MINER_MARON,
      BLACKSMITH_BRUNON, WAREHOUSE_KEEPER_MURDOC, WAREHOUSE_KEEPER_AIRY
    )
    add_kill_id(GOBLIN_BRIGAND_LEADER, GOBLIN_BRIGAND_LIEUTENANT, BLADE_BAT)
    register_quest_items(
      GOUPHS_CONTRACT, REEPS_CONTRACT, ELVEN_WINE, BRUNONS_DICE,
      BRUNONS_CONTRACT, AQUAMARINE, CHRYSOBERYL, GEM_BOX, COAL_PIECE,
      BRUNONS_LETTER, BERRY_TART, BAT_DIAGRAM, STAR_DIAMOND
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30523-04.htm"
      if st.created?
        st.start_quest
        st.give_items(GOUPHS_CONTRACT, 1)
        html = event
      end
    when "30555-02.html"
      if st.cond?(2) && st.has_quest_items?(REEPS_CONTRACT)
        st.take_items(REEPS_CONTRACT, -1)
        st.give_items(ELVEN_WINE, 1)
        st.set_cond(3, true)
        html = event
      end
    when "30526-02.html"
      if st.cond?(4) && st.has_quest_items?(BRUNONS_DICE)
        st.take_items(BRUNONS_DICE, -1)
        st.give_items(BRUNONS_CONTRACT, 1)
        st.set_cond(5, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when COLLECTOR_GOUPH
      case st.state
      when State::CREATED
        if !pc.race.dwarf?
          html = "30523-01.htm"
        elsif pc.level < MIN_LVL
          html = "30523-02.htm"
        else
          html = "30523-03.htm"
        end
      when State::STARTED
        case st.cond
        when 1
          if st.has_quest_items?(GOUPHS_CONTRACT)
            html = "30523-05.html"
          end
        when 2..6
          if has_at_least_one_quest_item?(pc, REEPS_CONTRACT, ELVEN_WINE, BRUNONS_DICE, BRUNONS_CONTRACT)
            html = "30523-06.html"
          end
        when 7
          if st.has_quest_items?(GEM_BOX)
            st.take_items(GEM_BOX, -1)
            st.give_items(COAL_PIECE, 1)
            st.set_cond(8, true)
            html = "30523-07.html"
          end
        when 8..11
          if has_at_least_one_quest_item?(pc, COAL_PIECE, BRUNONS_LETTER, BERRY_TART, BAT_DIAGRAM)
            html = "30523-08.html"
          end
        when 12
          if st.has_quest_items?(STAR_DIAMOND)
            Q00281_HeadForTheHills.give_newbie_reward(pc)
            st.add_exp_and_sp(34565, 2962)
            st.give_adena(14666, true)
            REWARDS.each { |reward| st.give_items(reward) }
            st.give_items(SILVERSMITH_HAMMER, 1)
            st.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "30523-09.html"
          end
        else
          # [automatically added else]
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when TRADER_REEP
      case st.cond
      when 1
        if st.has_quest_items?(GOUPHS_CONTRACT)
          st.take_items(GOUPHS_CONTRACT, -1)
          st.give_items(REEPS_CONTRACT, 1)
          st.set_cond(2, true)
          html = "30516-01.html"
        end
      when 2
        if st.has_quest_items?(REEPS_CONTRACT)
          html = "30516-02.html"
        end
      else
        if st.cond > 2
          html = "30516-02.html"
        end
      end
    when CARRIER_TOROCCO
      case st.cond
      when 2
        if st.has_quest_items?(REEPS_CONTRACT)
          html = "30555-01.html"
        end
      when 3
        if st.has_quest_items?(ELVEN_WINE)
          html = "30555-03.html"
        end
      when 7
        if st.has_quest_items?(GEM_BOX)
          html = "30555-04.html"
        end
      else
        if st.started?
          html = "30555-05.html"
        end
      end
    when MINER_MARON
      case st.cond
      when 3
        if st.has_quest_items?(ELVEN_WINE)
          st.take_items(ELVEN_WINE, -1)
          st.give_items(BRUNONS_DICE, 1)
          st.set_cond(4, true)
          html = "30529-01.html"
        end
      when 4
        if st.has_quest_items?(BRUNONS_DICE)
          html = "30529-02.html"
        end
      else
        if st.cond > 4
          html = "30529-03.html"
        end
      end
    when BLACKSMITH_BRUNON
      case st.cond
      when 4
        if st.has_quest_items?(BRUNONS_DICE)
          html = "30526-01.html"
        end
      when 5
        if st.has_quest_items?(BRUNONS_CONTRACT)
          html = "30526-03.html"
        end
      when 6
        if st.has_quest_items?(BRUNONS_CONTRACT)
          if st.get_quest_items_count(AQUAMARINE) >= MAX_GEM_COUNT
            if st.get_quest_items_count(CHRYSOBERYL) >= MAX_GEM_COUNT
              take_items(pc, -1, {BRUNONS_CONTRACT, AQUAMARINE, CHRYSOBERYL})
              st.give_items(GEM_BOX, 1)
              st.set_cond(7, true)
              html = "30526-04.html"
            end
          end
        end
      when 7
        if st.has_quest_items?(GEM_BOX)
          html = "30526-05.html"
        end
      when 8
        if st.has_quest_items?(COAL_PIECE)
          st.take_items(COAL_PIECE, -1)
          st.give_items(BRUNONS_LETTER, 1)
          st.set_cond(9, true)
          html = "30526-06.html"
        end
      when 9
        if st.has_quest_items?(BRUNONS_LETTER)
          html = "30526-07.html"
        end
      when 10, 11, 12
        if has_at_least_one_quest_item?(pc, BERRY_TART, BAT_DIAGRAM, STAR_DIAMOND)
          html = "30526-08.html"
        end
      else
        # [automatically added else]
      end

    when WAREHOUSE_KEEPER_MURDOC
      case st.cond
      when 9
        if st.has_quest_items?(BRUNONS_LETTER)
          st.take_items(BRUNONS_LETTER, -1)
          st.give_items(BERRY_TART, 1)
          st.set_cond(10, true)
          html = "30521-01.html"
        end
      when 10
        if st.has_quest_items?(BERRY_TART)
          html = "30521-02.html"
        end
      when 11, 12
        html = "30521-03.html"
      else
        # [automatically added else]
      end

    when WAREHOUSE_KEEPER_AIRY
      case st.cond
      when 10
        if st.has_quest_items?(BERRY_TART)
          st.take_items(BERRY_TART, -1)
          st.give_items(BAT_DIAGRAM, 1)
          st.set_cond(11, true)
          html = "30522-01.html"
        end
      when 11
        if st.has_quest_items?(BAT_DIAGRAM)
          html = "30522-02.html"
        end
      when 12
        if st.has_quest_items?(STAR_DIAMOND)
          html = "30522-03.html"
        end
      else
        if st.started?
          html = "30522-04.html"
        end
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when GOBLIN_BRIGAND_LEADER, GOBLIN_BRIGAND_LIEUTENANT
        if st.cond?(5) && st.has_quest_items?(BRUNONS_CONTRACT)
          chance = GOBLIN_DROP_CHANCES[npc.id]
          play_sound = false
          if st.give_item_randomly(npc, AQUAMARINE, 1, MAX_GEM_COUNT, chance, false)
            if st.get_quest_items_count(CHRYSOBERYL) >= MAX_GEM_COUNT
              st.set_cond(6, true)
            end

            play_sound = true
          end
          if st.give_item_randomly(npc, CHRYSOBERYL, 1, MAX_GEM_COUNT, chance, false)
            if st.get_quest_items_count(AQUAMARINE) >= MAX_GEM_COUNT
              st.set_cond(6, true)
            end

            play_sound = true
          end

          if play_sound
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when BLADE_BAT
        if st.cond?(11) && st.has_quest_items?(BAT_DIAGRAM)
          if st.give_item_randomly(npc, STAR_DIAMOND, 1, 1, 0.2, true)
            st.take_items(BAT_DIAGRAM, -1)
            st.set_cond(12)
          end
        end
      else
        # [automatically added else]
      end

    end

    super
  end
end
