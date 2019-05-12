class Scripts::Q00613_ProveYourCourageVarka < Quest
  # NPC
  private ASHAS = 31377
  # Monster
  private HEKATON = 25299
  # Items
  private HEKATON_HEAD = 7240
  private VALOR_FEATHER = 7229
  private VARKA_ALLIANCE_THREE = 7223
  # Misc
  private MIN_LEVEL = 75

  def initialize
    super(613, self.class.simple_name, "Prove Your Courage! (Varka)")

    add_start_npc(ASHAS)
    add_talk_id(ASHAS)
    add_kill_id(HEKATON)
    register_quest_items(HEKATON_HEAD)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, pc, false)
      st.give_items(HEKATON_HEAD, 1)
      st.set_cond(2, true)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31377-04.htm"
      st.start_quest
    when "31377-07.html"
      if st.has_quest_items?(HEKATON_HEAD) && st.cond?(2)
        st.give_items(VALOR_FEATHER, 1)
        st.add_exp_and_sp(10000, 0)
        st.exit_quest(true, true)
      else
        html = get_no_quest_msg(pc)
      end
    else
      html = nil
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, false)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      if pc.level >= MIN_LEVEL
        if st.has_quest_items?(VARKA_ALLIANCE_THREE)
          html = "31377-01.htm"
        else
          html = "31377-02.htm"
        end
      else
        html = "31377-03.htm"
      end
    when State::STARTED
      if st.cond?(2) && st.has_quest_items?(HEKATON_HEAD)
        html = "31377-05.html"
      else
        html = "31377-06.html"
      end
    end
    html || get_no_quest_msg(pc)
  end
end
