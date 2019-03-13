class Quests::Q00308_ReedFieldMaintenance < Quest
  # NPC
  private KATENSA = 32646
  # Mobs
  private AWAKENED_MUCROKIAN = 22655
  private MUCROKIAN = {
    22650 => 218, # Mucrokian Fanatic
    22651 => 258, # Mucrokian Ascetic
    22652 => 248, # Mucrokian Savior
    22653 => 290, # Mucrokian Preacher
    22654 => 220, # Contaminated Mucrokian
    22655 => 124  # Awakened Mucrokian
  }

  # Items
  private MUCROKIAN_HIDE = 14871
  private AWAKENED_MUCROKIAN_HIDE = 14872
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
    super(308, self.class.simple_name, "Reed Field Maintenance")

    add_start_npc(KATENSA)
    add_talk_id(KATENSA)
    add_kill_id(MUCROKIAN.keys)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32646-02.htm", "32646-03.htm", "32646-06.html", "32646-07.html",
         "32646-08.html", "32646-10.html"
      html = event
    when "32646-04.html"
      st.start_quest
      pc.send_packet(RadarControl.new(0, 2, 77325, 205773, -3432))
      html = event
    when "claimreward"
      if pc.quest_completed?(Q00238_SuccessFailureOfBusiness.class.name)
        html = "32646-09.html"
      else
        html = "32646-12.html"
      end
    when "100", "120"
      html = on_item_exchange_request(st, MOIRAI_PIECES.sample, event.to_i)
    when "192", "230"
      html = on_item_exchange_request(st, REC_DYNASTY_EARRINGS_70, event.to_i)
    when "256", "308"
      html = on_item_exchange_request(st, REC_DYNASTY_NECKLACE_70, event.to_i)
    when "128", "154"
      html = on_item_exchange_request(st, REC_DYNASTY_RING_70, event.to_i)
    when "206", "246"
      html = on_item_exchange_request(st, REC_DYNASTY_SIGIL_60, event.to_i)
    when "180", "216"
      html = on_item_exchange_request(st, MOIRAI_RECIPES.sample, event.to_i)
    when "32646-11.html"
      st.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if m = get_random_party_member(killer, 1)
      st = get_quest_state!(m, false)
      chance = MUCROKIAN[npc.id] * Config.rate_quest_drop
      if rand(1000) < chance
        if npc.id == AWAKENED_MUCROKIAN
          st.give_items(AWAKENED_MUCROKIAN_HIDE, 1)
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
    q309 = pc.get_quest_state(Q00309_ForAGoodCause.simple_name)

    if q309 && q309.started?
      html = "32646-15.html"
    elsif st.started?
      if st.has_quest_items?(MUCROKIAN_HIDE) || st.has_quest_items?(AWAKENED_MUCROKIAN_HIDE)
        html = "32646-06.html"
      else
        html = "32646-05.html"
      end
    else
      html = pc.level >= MIN_LEVEL ? "32646-01.htm" : "32646-00.html"
    end

    html || get_no_quest_msg(pc)
  end

  private def on_item_exchange_request(st, item, quanty)
    if can_give_item?(st, quanty)
      if MOIRAI_PIECES.includes?(item)
        st.give_items(item, rand(1..4))
      else
        st.give_items(item, 1)
      end
      st.play_sound(Sound::ITEMSOUND_QUEST_FINISH)
      html = "32646-14.html"
    else
      html = "32646-13.html"
    end

    html
  end

  private def can_give_item?(st, quanty)
    mucrokian = st.get_quest_items_count(MUCROKIAN_HIDE)
    awakened = st.get_quest_items_count(AWAKENED_MUCROKIAN_HIDE)
    if awakened > 0
      if awakened >= quanty / 2
        st.take_items(AWAKENED_MUCROKIAN_HIDE, quanty / 2)
        return true
      elsif mucrokian >= quanty - (awakened * 2)
        st.take_items(AWAKENED_MUCROKIAN_HIDE, awakened)
        st.take_items(MUCROKIAN_HIDE, quanty - (awakened * 2))
        return true
      end
    elsif mucrokian >= quanty
      st.take_items(MUCROKIAN_HIDE, quanty)
      return true
    end

    false
  end
end
