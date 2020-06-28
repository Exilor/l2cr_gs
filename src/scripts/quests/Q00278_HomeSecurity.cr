class Scripts::Q00278_HomeSecurity < Quest
  # NPC
  private TUNATUN = 31537
  private MONSTER = {
    18905,
    18906,
    18907
  }
  # Item
  private SEL_MAHUM_MANE = 15531
  # Misc
  private SEL_MAHUM_MANE_COUNT = 300

  def initialize
    super(278, self.class.simple_name, "Home Security")

    add_start_npc(TUNATUN)
    add_talk_id(TUNATUN)
    add_kill_id(MONSTER)
    register_quest_items(SEL_MAHUM_MANE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "31537-02.htm"
      html = pc.level >= 82 ? "31537-02.htm" : "31537-03.html"
    when "31537-04.htm"
      st.start_quest
    when "31537-07.html"
      i0 = Rnd.rand(100)

      if i0 < 10
        st.give_items(960, 1)
      elsif i0 < 19
        st.give_items(960, 2)
      elsif i0 < 27
        st.give_items(960, 3)
      elsif i0 < 34
        st.give_items(960, 4)
      elsif i0 < 40
        st.give_items(960, 5)
      elsif i0 < 45
        st.give_items(960, 6)
      elsif i0 < 49
        st.give_items(960, 7)
      elsif i0 < 52
        st.give_items(960, 8)
      elsif i0 < 54
        st.give_items(960, 9)
      elsif i0 < 55
        st.give_items(960, 10)
      elsif i0 < 75
        st.give_items(9553, 1)
      elsif i0 < 90
        st.give_items(9553, 2)
      else
        st.give_items(959, 1)
      end

      st.exit_quest(true, true)
      html = "31537-07.html"
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_random_party_member_state(pc, 1, 3, npc)
      case npc.id
      when 18905 # Farm Ravager (Crazy)
        count = (Rnd.rand(1000) < 486 ? Rnd.rand(6) : Rnd.rand(5)) + 1
        if st.give_item_randomly(npc, SEL_MAHUM_MANE, count, SEL_MAHUM_MANE_COUNT, 1.0, true)
          st.set_cond(2, true)
        end
      when 18906, # Farm Bandit
           18907  # Beast Devourer
        if st.give_item_randomly(npc, SEL_MAHUM_MANE, 1, SEL_MAHUM_MANE_COUNT, 0.85, true)
          st.set_cond(2, true)
        end
      end

    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = "31537-01.htm"
    elsif st.started?
      if st.cond?(1) || get_quest_items_count(pc, SEL_MAHUM_MANE) < SEL_MAHUM_MANE_COUNT
        html = "31537-06.html"
      elsif st.cond?(2) && get_quest_items_count(pc, SEL_MAHUM_MANE) >= SEL_MAHUM_MANE_COUNT
        html = "31537-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
