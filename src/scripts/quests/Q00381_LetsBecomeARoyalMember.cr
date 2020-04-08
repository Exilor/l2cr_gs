class Scripts::Q00381_LetsBecomeARoyalMember < Quest
  # NPCs
  private SANDRA = 30090
  private SORINT = 30232
  # Items
  private COLLECTOR_MEMBERSHIP_1 = 3813
  private KAILS_COIN = 5899
  private FOUR_LEAF_COIN = 7569
  private COIN_ALBUM = 5900
  # Monsters
  private ANCIENT_GARGOYLE = 21018
  private FALLEN_CHIEF_VERGUS = 27316
  # Reward
  private ROYAL_MEMBERSHIP = 5898
  # Misc
  private MIN_LVL = 55

  def initialize
    super(381, self.class.simple_name, "Let's Become a Royal Member!")

    add_start_npc(SORINT)
    add_talk_id(SORINT, SANDRA)
    add_kill_id(ANCIENT_GARGOYLE, FALLEN_CHIEF_VERGUS)
    register_quest_items(KAILS_COIN, FOUR_LEAF_COIN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30232-03.htm"
      if qs.created?
        qs.start_quest
        qs.memo_state = 1
        html = event
      end
    when "30090-02.html"
      if qs.memo_state?(1) && !has_quest_items?(pc, COIN_ALBUM)
        qs.memo_state = 2
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        html = event
      end
    else
      # automatically added
    end


    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case npc.id
    when SORINT
      if qs.created?
        if pc.level < MIN_LVL || !has_quest_items?(pc, COLLECTOR_MEMBERSHIP_1)
          html = "30232-02.html"
        elsif !has_quest_items?(pc, ROYAL_MEMBERSHIP)
          html = "30232-01.htm"
        end
        # TODO this quest is not visible in quest list if either of these IF blocks are true
      elsif qs.started?
        has_album = has_quest_items?(pc, COIN_ALBUM)
        has_coin = has_quest_items?(pc, KAILS_COIN)

        if has_album && has_coin
          take_items(pc, 1, {KAILS_COIN, COIN_ALBUM})
          give_items(pc, ROYAL_MEMBERSHIP, 1)
          qs.exit_quest(false, true)
          html = "30232-06.html"
        elsif has_album || has_coin
          html = "30232-05.html"
        else
          html = "30232-04.html"
        end
      else
        html = get_already_completed_msg(pc)
      end
    when SANDRA
      case qs.memo_state
      when 1
        html = "30090-01.html"
      when 2
        if has_quest_items?(pc, COIN_ALBUM)
          html = "30090-05.html"
        elsif has_quest_items?(pc, FOUR_LEAF_COIN)
          take_items(pc, FOUR_LEAF_COIN, 1)
          give_items(pc, COIN_ALBUM, 1)
          play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
          html = "30090-04.html"
        else
          html = "30090-03.html"
        end
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      if npc.id == ANCIENT_GARGOYLE
        give_item_randomly(killer, npc, KAILS_COIN, 1, 1, 0.05, true)
      elsif qs.memo_state?(2) && !has_quest_items?(killer, FOUR_LEAF_COIN)
        give_items(killer, FOUR_LEAF_COIN, 1)
        play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
      end
    end

    super
  end
end