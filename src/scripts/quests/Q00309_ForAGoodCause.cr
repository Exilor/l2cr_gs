class Scripts::Q00309_ForAGoodCause < Quest
  # NPC
  private ATRA = 32647
  # Mobs
  private CORRUPTED_MUCROKIAN = 22654
  private MUCROKIANS = {
    22650 => 218, # Mucrokian Fanatic
    22651 => 258, # Mucrokian Ascetic
    22652 => 248, # Mucrokian Savior
    22653 => 290, # Mucrokian Preacher
    22654 => 124, # Contaminated Mucrokian
    22655 => 220  # Awakened Mucrokian
  }

  # Items
  private MUCROKIAN_HIDE = 14873
  private FALLEN_MUCROKIAN_HIDE = 14874
  # Rewards
  private REC_DYNASTY_EARRINGS_70 = 9985
  private REC_DYNASTY_NECKLACE_70 = 9986
  private REC_DYNASTY_RING_70 = 9987
  private REC_DYNASTY_SIGIL_60 = 10115

  private MOIRAI_RECIPES = {
    15777,
    15780,
    15783,
    15786,
    15789,
    15790,
    15814,
    15813,
    15812
  }

  private MOIRAI_PIECES = {
    15647,
    15650,
    15653,
    15656,
    15659,
    15692,
    15772,
    15773,
    15774
  }

  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(309, self.class.simple_name, "For A Good Cause")

    add_start_npc(ATRA)
    add_talk_id(ATRA)
    add_kill_id(MUCROKIANS.keys)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32647-02.htm", "32647-03.htm", "32647-04.htm", "32647-08.html",
         "32647-10.html", "32647-12.html", "32647-13.html"
      html = event
    when "32647-05.html"
      st.start_quest
      pc.send_packet(RadarControl.new(0, 2, 77325, 205773, -3432))
      html = event
    when "claimreward"
      if pc.quest_completed?(Q00239_WontYouJoinUs.simple_name)
        html = "32647-11.html"
      else
        html = "32647-09.html"
      end
    when "100", "120"
      html = on_item_exchange_request(st, MOIRAI_PIECES.sample(random: Rnd), event.to_i)
    when "192", "230"
      html = on_item_exchange_request(st, REC_DYNASTY_EARRINGS_70, event.to_i)
    when "256", "308"
      html = on_item_exchange_request(st, REC_DYNASTY_NECKLACE_70, event.to_i)
    when "128", "154"
      html = on_item_exchange_request(st, REC_DYNASTY_RING_70, event.to_i)
    when "206", "246"
      html = on_item_exchange_request(st, REC_DYNASTY_SIGIL_60, event.to_i)
    when "180", "216"
      html = on_item_exchange_request(st, MOIRAI_RECIPES.sample(random: Rnd), event.to_i)
    when "32647-14.html", "32647-07.html"
      st.exit_quest(true, true)
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if m = get_random_party_member(killer, 1)
      st = get_quest_state!(m, false)
      chance = MUCROKIANS[npc.id] * Config.rate_quest_drop
      if Rnd.rand(1000) < chance
        if npc.id == CORRUPTED_MUCROKIAN
          st.give_items(FALLEN_MUCROKIAN_HIDE, 1)
          st.reward_items(FALLEN_MUCROKIAN_HIDE, 1)
        else
          st.give_items(MUCROKIAN_HIDE, 1)
        end
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    q308 = pc.get_quest_state(Q00308_ReedFieldMaintenance.simple_name)
    if q308 && q308.started?
      html = "32647-17.html"
    elsif st.started?
      if st.has_quest_items?(MUCROKIAN_HIDE) || st.has_quest_items?(FALLEN_MUCROKIAN_HIDE)
        html = "32647-08.html"
      else
        html = "32647-06.html"
      end
    else
      html = pc.level >= MIN_LEVEL ? "32647-01.htm" : "32647-00.html"
    end

    html || get_no_quest_msg(pc)
  end

  private def can_give_item?(st, quanty)
    mucrokian = st.get_quest_items_count(MUCROKIAN_HIDE)
    fallen = st.get_quest_items_count(FALLEN_MUCROKIAN_HIDE)
    if fallen > 0
      if fallen >= quanty // 2
        st.take_items(FALLEN_MUCROKIAN_HIDE, quanty // 2)
        return true
      elsif mucrokian >= quanty - (fallen * 2)
        st.take_items(FALLEN_MUCROKIAN_HIDE, fallen)
        st.take_items(MUCROKIAN_HIDE, quanty - (fallen * 2))
        return true
      end
    elsif mucrokian >= quanty
      st.take_items(MUCROKIAN_HIDE, quanty)
      return true
    end

    false
  end

  private def on_item_exchange_request(st, item, quanty)
    if can_give_item?(st, quanty)
      if MOIRAI_PIECES.includes?(item)
        st.give_items(item, Rnd.rand(1..4))
      else
        st.give_items(item, 1)
      end
      st.play_sound(Sound::ITEMSOUND_QUEST_FINISH)
      html = "32646-16.htm"
    else
      html = "32646-15.htm"
    end

    html
  end
end
