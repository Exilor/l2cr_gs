class Quests::Q00133_ThatsBloodyHot < Quest
  # NPCs
  private KANIS = 32264
  private GALATE = 32292
  # Item
  private REFINED_CRYSTAL_SAMPLE = 9785
  # Misc
  private MIN_LEVEL = 78

  def initialize
    super(133, self.class.simple_name, "That's Bloody Hot!")

    add_start_npc(KANIS)
    add_talk_id(KANIS, GALATE)
    register_quest_items(REFINED_CRYSTAL_SAMPLE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    case event
    when "32264-04.html"
      if player.level >= MIN_LEVEL
        st.start_quest
        htmltext = event
      end
    when "32264-06.html", "32264-07.html"
      if st.cond?(1)
        htmltext = event
      end
    when "32264-08.html"
      st.set_cond(2)
      htmltext = event
    when "32264-10.html", "32264-11.html"
      if st.cond?(2)
        htmltext = event
      end
    when "32264-12.html"
      if st.cond?(2)
        st.give_items(REFINED_CRYSTAL_SAMPLE, 1)
        st.set_cond(3)
        htmltext = event
      end
    when "32292-03.html"
      if st.cond?(3)
        htmltext = event
      end
    when "32292-05.html"
      if st.cond?(3) && st.has_quest_items?(REFINED_CRYSTAL_SAMPLE)
        st.take_items(REFINED_CRYSTAL_SAMPLE, -1)
        htmltext = event
        st.set_cond(4)
      end
    when "32292-06.html"
      if st.cond?(4)
        if !HellboundEngine.locked?
          st.give_adena(254247, true)
          st.add_exp_and_sp(331457, 32524)
          st.exit_quest(false, true)
          htmltext = event
        else
          HellboundEngine.level = 1
          st.give_adena(254247, true)
          st.add_exp_and_sp(325881, 32524)
          st.exit_quest(false, true)
          htmltext = "32292-07.html"
        end
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc.id == KANIS
        if player.quest_completed?(Q00131_BirdInACage.simple_name)
          htmltext = player.level >= MIN_LEVEL ? "32264-01.htm" : "32264-02.html"
        else
          htmltext = "32264-03.html"
        end
      end
    when State::STARTED
      if npc.id == KANIS
        if st.cond?(1)
          htmltext = "32264-05.html"
        elsif st.cond?(2)
          htmltext = "32264-09.html"
        elsif st.cond >= 3
          htmltext = "32264-13.html"
        end
      elsif npc.id == GALATE
        if st.cond < 3
          htmltext = "32292-01.html"
        elsif st.cond?(3)
          htmltext = "32292-02.html"
        elsif st.cond?(4)
          htmltext = "32292-04.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
