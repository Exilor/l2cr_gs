class Scripts::Q00157_RecoverSmuggledGoods < Quest
  # NPC
  private WILFORD = 30005
  # Monster
  private GIANT_TOAD = 20121
  # Items
  private BUCKLER = 20
  private ADAMANTITE_ORE = 1024
  # Misc
  private MIN_LVL = 5

  def initialize
    super(157, self.class.simple_name, "Recover Smuggled Goods")

    add_start_npc(WILFORD)
    add_talk_id(WILFORD)
    add_kill_id(GIANT_TOAD)
    register_quest_items(ADAMANTITE_ORE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)

    if st
      case event
      when "30005-03.htm"
        html = event
      when "30005-04.htm"
        st.start_quest
        html = event
      else
        # automatically added
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    return super unless st = get_quest_state(killer, false)

    if st.cond?(1) && Rnd.rand(10) < 4 && st.get_quest_items_count(ADAMANTITE_ORE) < 20
      st.give_items(ADAMANTITE_ORE, 1)
      if st.get_quest_items_count(ADAMANTITE_ORE) >= 20
        st.set_cond(2, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state(pc, true)
    html = get_no_quest_msg(pc)
    if st
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "30005-02.htm" : "30005-01.htm"
      when State::STARTED
        if st.cond?(2) && st.get_quest_items_count(ADAMANTITE_ORE) >= 20
          st.give_items(BUCKLER, 1)
          st.exit_quest(false, true)
          html = "30005-06.html"
        else
          html = "30005-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    end

    html
  end
end