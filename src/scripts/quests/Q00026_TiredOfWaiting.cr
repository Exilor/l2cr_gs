class Scripts::Q00026_TiredOfWaiting < Quest
  # NPCs
  private ISAEL_SILVERSHADOW = 30655
  private KITZKA = 31045
  # Items
  private DELIVERY_BOX = 17281
  private REWARDS = {
    "31045-10.html" => 17248, # Large Dragon Bone
    "31045-11.html" => 17266, # Will of Antharas
    "31045-12.html" => 17267  # Sealed Blood Crystal
  }

  def initialize
    super(26, self.class.simple_name, "Tired of Waiting")

    add_start_npc(ISAEL_SILVERSHADOW)
    add_talk_id(ISAEL_SILVERSHADOW, KITZKA)
    register_quest_items(DELIVERY_BOX)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30655-02.htm",  "30655-03.htm",  "30655-05.html", "30655-06.html",
         "31045-02.html", "31045-03.html", "31045-05.html", "31045-06.html",
         "31045-07.html", "31045-08.html", "31045-09.html"
      html = event
    when "30655-04.html"
      if st.created?
        st.give_items(DELIVERY_BOX, 1)
        st.start_quest
        html = event
      end
    when "31045-04.html"
      if st.started?
        st.take_items(DELIVERY_BOX, -1)
        html = event
      end
    when "31045-10.html", "31045-11.html", "31045-12.html"
      if st.started?
        st.give_items(REWARDS[event], 1)
        st.exit_quest(false, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    html = get_no_quest_msg(pc)
    st = get_quest_state!(pc)

    case npc.id
    when ISAEL_SILVERSHADOW
      if st.created?
        html = pc.level >= 80 ? "30655-01.htm" : "30655-00.html"
      elsif st.started?
        html = "30655-07.html"
      else
        html = "30655-08.html"
      end
    when KITZKA
      if st.started?
        html = st.has_quest_items?(DELIVERY_BOX) ? "31045-01.html" : "31045-09.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
