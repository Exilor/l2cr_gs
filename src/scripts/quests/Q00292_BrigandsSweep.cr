class Quests::Q00292_BrigandsSweep < Quest
  # NPCs
  private SPIRON = 30532
  private BALANKI = 30533
  # Items
  private GOBLIN_NECKLACE = 1483
  private GOBLIN_PENDANT = 1484
  private GOBLIN_LORD_PENDANT = 1485
  private SUSPICIOUS_MEMO = 1486
  private SUSPICIOUS_CONTRACT = 1487
  # Monsters
  private MOB_ITEM_DROP = {
    20322 => GOBLIN_NECKLACE,    # Goblin Brigand
    20323 => GOBLIN_PENDANT,     # Goblin Brigand Leader
    20324 => GOBLIN_NECKLACE,    # Goblin Brigand Lieutenant
    20327 => GOBLIN_NECKLACE,    # Goblin Snooper
    20528 => GOBLIN_LORD_PENDANT # Goblin Lord
  }
  # Misc
  private MIN_LVL = 5

  def initialize
    super(292, self.class.simple_name, "Brigands Sweep")

    add_start_npc(SPIRON)
    add_talk_id(SPIRON, BALANKI)
    add_kill_id(MOB_ITEM_DROP.keys)
    register_quest_items(GOBLIN_NECKLACE, GOBLIN_PENDANT, GOBLIN_LORD_PENDANT, SUSPICIOUS_MEMO, SUSPICIOUS_CONTRACT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "30532-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30532-06.html"
      if qs.started?
        qs.exit_quest(true, true)
        html = event
      end
    when "30532-07.html"
      if qs.started?
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      chance = Rnd.rand(10)
      if chance > 5
        give_item_randomly(killer, npc, MOB_ITEM_DROP[npc.id], 1, 0, 1.0, true)
      elsif qs.cond?(1) && (chance > 4) && !has_quest_items?(killer, SUSPICIOUS_CONTRACT)
         memos = get_quest_items_count(killer, SUSPICIOUS_MEMO)
        if memos < 3
          if give_item_randomly(killer, npc, SUSPICIOUS_MEMO, 1, 3, 1.0, false)
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            give_items(killer, SUSPICIOUS_CONTRACT, 1)
            take_items(killer, SUSPICIOUS_MEMO, -1)
            qs.set_cond(2, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, talker)
    qs = get_quest_state!(talker)
    html = get_no_quest_msg(talker)
    case npc.id
    when SPIRON
      case qs.state
      when State::CREATED
        html = talker.race.dwarf? ? talker.level >= MIN_LVL ? "30532-02.htm" : "30532-01.htm" : "30532-00.htm"
      when State::STARTED
        if !has_at_least_one_quest_item?(talker, registered_item_ids)
          html = "30532-04.html"
        else
          necklaces = get_quest_items_count(talker, GOBLIN_NECKLACE)
          pendants = get_quest_items_count(talker, GOBLIN_PENDANT)
          lord_pendants = get_quest_items_count(talker, GOBLIN_LORD_PENDANT)
          sum = necklaces + pendants + lord_pendants
          if sum > 0
            give_adena(talker, (necklaces * 12) + (pendants * 36) + (lord_pendants * 33) + (sum >= 10 ? 1000 : 0), true)
            take_items(talker, -1, {GOBLIN_NECKLACE, GOBLIN_PENDANT, GOBLIN_LORD_PENDANT})
          end

          if sum > 0 && !has_at_least_one_quest_item?(talker, SUSPICIOUS_MEMO, SUSPICIOUS_CONTRACT)
            html = "30532-05.html"
          else
            memos = get_quest_items_count(talker, SUSPICIOUS_MEMO)
            if memos == 0 && has_quest_items?(talker, SUSPICIOUS_CONTRACT)
              give_adena(talker, 1120, true)
              take_items(talker, -1, {SUSPICIOUS_CONTRACT}) # Retail like, reward is given in 2 pieces if both conditions are meet.
              html = "30532-10.html"
            else
              if memos == 1
                html = "30532-08.html"
              elsif memos >= 2
                html = "30532-09.html"
              end
            end
          end
        end
      end
    when BALANKI
      if qs.started?
        if has_quest_items?(talker, SUSPICIOUS_CONTRACT)
          give_adena(talker, 620, true)
          take_items(talker, 1487, -1)
          html = "30533-02.html"
        else
          html = "30533-01.html"
        end
      end
    end

    html
  end
end
