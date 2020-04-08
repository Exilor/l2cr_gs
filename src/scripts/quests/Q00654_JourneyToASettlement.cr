class Scripts::Q00654_JourneyToASettlement < Quest
  # NPC
  private NAMELESS_SPIRIT = 31453
  # Items
  private ANTELOPE_SKIN = 8072
  private FRINTEZZAS_SCROLL = 8073
  # Misc
  private MIN_LEVEL = 74

  private MOBS_SKIN = {
    21294 => 0.840, # Canyon Antelope
    21295 => 0.893  # Canyon Antelope Slave
  }

  def initialize
    super(654, self.class.simple_name, "Journey to a Settlement")

    add_start_npc(NAMELESS_SPIRIT)
    add_talk_id(NAMELESS_SPIRIT)
    add_kill_id(MOBS_SKIN.keys)
    register_quest_items(ANTELOPE_SKIN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "31453-02.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "31453-03.html"
      if st.memo_state?(1)
        st.memo_state = 2
        st.set_cond(2, true)
        html = event
      end
    when "31453-07.html"
      if st.memo_state?(2) && st.has_quest_items?(ANTELOPE_SKIN)
        give_items(pc, FRINTEZZAS_SCROLL, 1)
        st.exit_quest(true, true)
        html = event
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_random_party_member_state(pc, 2, 3, npc)
    if st && give_item_randomly(st.player, npc, ANTELOPE_SKIN, 1, 1, MOBS_SKIN[npc.id], true)
      st.set_cond(3)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00119_LastImperialPrince.simple_name)
        html = "31453-01.htm"
      else
        html = "31453-04.htm"
      end
    elsif st.started?
      if st.memo_state?(1)
        st.memo_state = 2
        st.set_cond(2, true)
        html = "31453-03.html"
      elsif st.memo_state?(2)
        if has_quest_items?(pc, ANTELOPE_SKIN)
          html = "31453-06.html"
        else
          html = "31453-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end