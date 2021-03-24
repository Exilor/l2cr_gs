class Scripts::Q00131_BirdInACage < Quest
  # NPCs
  private KANIS = 32264
  private PARME = 32271
  # Items
  private ECHO_CRYSTAL_OF_FREE_THOUGHT = 9783
  private PARMES_LETTER = 9784
  private FIRE_STONE = 9546
  # Locations
  private INSTANCE_EXIT = Location.new(143281, 148843, -12004)
  # Misc
  private MIN_LEVEL = 78

  def initialize
    super(131, self.class.simple_name, "Bird in a Cage")

    add_start_npc(KANIS)
    add_talk_id(KANIS, PARME)
    register_quest_items(ECHO_CRYSTAL_OF_FREE_THOUGHT, PARMES_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "32264-04.html"
      if pc.level >= MIN_LEVEL
        st.start_quest
        html = event
      end
    when "32264-06.html"
      if st.cond?(1)
        html = event
      end
    when "32264-07.html"
      if st.cond?(1)
        st.set_cond(2)
        html = event
      end
    when "32264-09.html", "32264-10.html", "32264-11.html"
      if st.cond?(2)
        html = event
      end
    when "32264-12.html"
      if st.cond?(2)
        st.give_items(ECHO_CRYSTAL_OF_FREE_THOUGHT, 1)
        st.set_cond(3, true)
        html = event
      end
    when "32264-14.html", "32264-15.html"
      if st.cond?(3)
        html = event
      end
    when "32264-17.html"
      if st.cond?(4) && st.has_quest_items?(PARMES_LETTER)
        st.take_items(PARMES_LETTER, -1)
        st.set_cond(5)
        html = event
      end
    when "32264-19.html"
      if st.cond?(5) && st.has_quest_items?(ECHO_CRYSTAL_OF_FREE_THOUGHT)
        st.add_exp_and_sp(250_677, 25_019)
        st.give_items(FIRE_STONE &+ Rnd.rand(4), 4)
        st.exit_quest(false, true)
        html = event
      end
    when "32271-03.html"
      if st.cond?(3)
        html = event
      end
    when "32271-04.html"
      if st.cond?(3)
        st.give_items(PARMES_LETTER, 1)
        st.set_cond(4, true)
        pc.instance_id = 0
        pc.tele_to_location(INSTANCE_EXIT, true)
        html = event
      end
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
        html = pc.level >= MIN_LEVEL ? "32264-01.htm" : "32264-02.html"
      end
    when State::STARTED
      if npc.id == KANIS
        case st.cond
        when 1
          html = "32264-05.html"
        when 2
          html = "32264-08.html"
        when 3
          html = "32264-13.html"
        when 4
          html = "32264-16.html"
        when 5
          html = "32264-18.html"
        end
      elsif npc.id == PARME
        if st.cond < 3
          html = "32271-01.html"
        elsif st.cond?(3)
          html = "32271-02.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
