class Scripts::Q00133_ThatsBloodyHot < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32264-04.html"
      if pc.level >= MIN_LEVEL
        st.start_quest
        html = event
      end
    when "32264-06.html", "32264-07.html"
      if st.cond?(1)
        html = event
      end
    when "32264-08.html"
      st.set_cond(2)
      html = event
    when "32264-10.html", "32264-11.html"
      if st.cond?(2)
        html = event
      end
    when "32264-12.html"
      if st.cond?(2)
        st.give_items(REFINED_CRYSTAL_SAMPLE, 1)
        st.set_cond(3)
        html = event
      end
    when "32292-03.html"
      if st.cond?(3)
        html = event
      end
    when "32292-05.html"
      if st.cond?(3) && st.has_quest_items?(REFINED_CRYSTAL_SAMPLE)
        st.take_items(REFINED_CRYSTAL_SAMPLE, -1)
        html = event
        st.set_cond(4)
      end
    when "32292-06.html"
      if st.cond?(4)
        if !HellboundEngine.locked?
          st.give_adena(254247, true)
          st.add_exp_and_sp(331457, 32524)
          st.exit_quest(false, true)
          html = event
        else
          HellboundEngine.level = 1
          st.give_adena(254247, true)
          st.add_exp_and_sp(325881, 32524)
          st.exit_quest(false, true)
          html = "32292-07.html"
        end
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == KANIS
        if pc.quest_completed?(Q00131_BirdInACage.simple_name)
          html = pc.level >= MIN_LEVEL ? "32264-01.htm" : "32264-02.html"
        else
          html = "32264-03.html"
        end
      end
    when State::STARTED
      if npc.id == KANIS
        if st.cond?(1)
          html = "32264-05.html"
        elsif st.cond?(2)
          html = "32264-09.html"
        elsif st.cond >= 3
          html = "32264-13.html"
        end
      elsif npc.id == GALATE
        if st.cond < 3
          html = "32292-01.html"
        elsif st.cond?(3)
          html = "32292-02.html"
        elsif st.cond?(4)
          html = "32292-04.html"
        end
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
