class Scripts::Q00659_IdRatherBeCollectingFairyBreath < Quest
  # NPC
  private GALATEA = 30634
  # Item
  private FAIRY_BREATH = 8286
  # Misc
  private MIN_LEVEL = 26
  # Mobs
  private MOBS = {
    20078 => 0.98, # whispering_wind
    21023 => 0.82, # sobing_wind
    21024 => 0.86, # babbleing_wind
    21025 => 0.90, # giggleing_wind
    21026 => 0.96  # singing_wind
  }

  def initialize
    super(659, self.class.simple_name, "I'd Rather Be Collecting Fairy Breath")

    add_start_npc(GALATEA)
    add_talk_id(GALATEA)
    add_kill_id(MOBS.keys)
    register_quest_items(FAIRY_BREATH)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30634-02.htm"
      st.start_quest
      html = event
    when "REWARD"
      if has_quest_items?(pc, FAIRY_BREATH)
        count = get_quest_items_count(pc, FAIRY_BREATH)
        bonus = count >= 10 ? 5365 : 0
        st.take_items(FAIRY_BREATH, -1)
        st.give_adena((count * 50) + bonus, true)
        html = "30634-05.html"
      else
        html = "30634-06.html"
      end
    when "30634-07.html"
      html = event
    when "30634-08.html"
      st.exit_quest(true, true)
      html = event
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_random_party_member_state(pc, -1, 3, npc)
      st.give_item_randomly(npc, FAIRY_BREATH, 1, 0, MOBS[npc.id], true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30634-01.htm" : "30634-03.html"
    elsif st.started?
      if has_quest_items?(pc, FAIRY_BREATH)
        html = "30634-04.html"
      else
        html = "30634-09.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end