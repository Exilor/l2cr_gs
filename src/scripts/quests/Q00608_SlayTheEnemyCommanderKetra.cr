class Scripts::Q00608_SlayTheEnemyCommanderKetra < Quest
  # NPC
  private KADUN = 31370
  # Monster
  private MOS = 25312
  # Items
  private MOS_HEAD = 7236
  private WISDOM_TOTEM = 7220
  private KETRA_ALLIANCE_FOUR = 7214
  # Misc
  private MIN_LEVEL = 75

  def initialize
    super(608, self.class.simple_name, "Slay the Enemy Commander! (Ketra)")

    add_start_npc(KADUN)
    add_talk_id(KADUN)
    add_kill_id(MOS)
    register_quest_items(MOS_HEAD)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, pc, false)
      st.give_items(MOS_HEAD, 1)
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
    when "31370-04.htm"
      st.start_quest
    when "31370-07.html"
      if st.has_quest_items?(MOS_HEAD) && st.cond?(2)
        st.give_items(WISDOM_TOTEM, 1)
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
        if st.has_quest_items?(KETRA_ALLIANCE_FOUR)
          html = "31370-01.htm"
        else
          html = "31370-02.htm"
        end
      else
        html = "31370-03.htm"
      end
    when State::STARTED
      if st.cond?(2) && st.has_quest_items?(MOS_HEAD)
        html = "31370-05.html"
      else
        html = "31370-06.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
