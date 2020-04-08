class Scripts::Q00250_WatchWhatYouEat < Quest
  # NPCs
  private SALLY = 32743
  # Mobs -> Items
  private MOBS = {
    {18864, 15493},
    {18865, 15494},
    {18868, 15495}
  }

  def initialize
    super(250, self.class.simple_name, "Watch What You Eat")

    add_start_npc(SALLY)
    add_first_talk_id(SALLY)
    add_talk_id(SALLY)
    MOBS.each do |mob|
      add_kill_id(mob[0])
    end
    register_quest_items(15493, 15494, 15495)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    npc = npc.not_nil!

    if npc.id == SALLY
      if event.casecmp?("32743-03.htm")
        st.start_quest
      elsif event.casecmp?("32743-end.htm")
        st.give_adena(135661, true)
        st.add_exp_and_sp(698334, 76369)
        st.exit_quest(false, true)
      elsif event.casecmp?("32743-22.html") && st.completed?
        html = "32743-23.html"
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    if npc.id == SALLY
      return "32743-20.html"
    end

    nil
  end

  def on_kill(npc, pc, is_summon)
    unless st = get_quest_state(pc, false)
      return
    end
    if st.started? && st.cond?(1)
      MOBS.each do |mob|
        if npc.id == mob[0]
          unless st.has_quest_items?(mob[1])
            st.give_items(mob[1], 1)
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
      if st.has_quest_items?(MOBS[0][1]) && st.has_quest_items?(MOBS[1][1])
        if st.has_quest_items?(MOBS[2][1])
          st.set_cond(2, true)
        end
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if npc.id == SALLY
      case st.state
      when State::CREATED
        html = pc.level >= 82 ? "32743-01.htm" : "32743-00.htm"
      when State::STARTED
        if st.cond?(1)
          html = "32743-04.htm"
        elsif st.cond?(2)
          if st.has_quest_items?(MOBS[0][1]) && st.has_quest_items?(MOBS[1][1]) && st.has_quest_items?(MOBS[2][1])
            html = "32743-05.htm"
            MOBS.each { |items| st.take_items(items[1], -1) }
          else
            html = "32743-06.htm"
          end
        end
      when State::COMPLETED
        html = "32743-done.htm"
      else
        # automatically added
      end

    end

    html || get_no_quest_msg(pc)
  end
end