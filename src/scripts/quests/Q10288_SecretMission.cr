class Scripts::Q10288_SecretMission < Quest
  # NPCs
  private DOMINIC = 31350
  private AQUILANI = 32780
  private GREYMORE = 32757
  # Item
  private LETTER = 15529
  # Location
  private TELEPORT = Location.new(118833, -80589, -2688)

  def initialize
    super(10288, self.class.simple_name, "Secret Mission")

    add_start_npc(AQUILANI, DOMINIC)
    add_first_talk_id(AQUILANI)
    add_talk_id(DOMINIC, GREYMORE, AQUILANI)
    register_quest_items(LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end
    html = event

    case event
    when "31350-03.html"
      if pc.level < 82
        html = "31350-02b.html"
      end
    when "31350-05.htm"
      st.start_quest
      st.give_items(LETTER, 1)
    when "32780-03.html"
      if st.cond?(1) && st.has_quest_items?(LETTER)
        st.set_cond(2, true)
      end
    when "32757-03.html"
      if st.cond?(2) && st.has_quest_items?(LETTER)
        st.give_adena(106583, true)
        st.add_exp_and_sp(417788, 46320)
        st.exit_quest(false, true)
      end
    when "teleport"
      if npc.not_nil!.id == AQUILANI && st.completed?
        pc.tele_to_location(TELEPORT)
        return
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    st = get_quest_state(pc, false)
    # dialog only changes when you talk to Aquilani after quest completion
    if st && st.completed?
      return "32780-05.html"
    end

    "data/html/default/32780.htm"
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when DOMINIC
      case st.state
      when State::CREATED
        html = "31350-01.htm"
      when State::STARTED
        if st.cond?(1)
          html = "31350-06.html"
        end
      when State::COMPLETED
        html = "31350-07.html"
      end
    when AQUILANI
      if st.started?
        if st.cond?(1) && st.has_quest_items?(LETTER)
          html = "32780-01.html"
        elsif st.cond?(2)
          html = "32780-04.html"
        end
      end
    when GREYMORE
      if st.started? && st.cond?(2) && st.has_quest_items?(LETTER)
        return "32757-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
