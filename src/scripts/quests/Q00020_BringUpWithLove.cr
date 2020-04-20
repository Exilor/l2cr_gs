class Scripts::Q00020_BringUpWithLove < Quest
  # NPC
  private TUNATUN = 31537
  # Items
  private WATER_CRYSTAL = 9553
  private INNOCENCE_JEWEL = 15533
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(20, self.class.simple_name, "Bring Up With Love")

    add_start_npc(TUNATUN)
    add_talk_id(TUNATUN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "31537-02.htm", "31537-03.htm", "31537-04.htm", "31537-05.htm",
         "31537-06.htm", "31537-07.htm", "31537-08.htm", "31537-09.htm",
         "31537-10.htm", "31537-12.htm"
      html = event
    when "31537-11.html"
      st.start_quest
      html = event
    when "31537-16.html"
      if st.cond?(2) && st.has_quest_items?(INNOCENCE_JEWEL)
        st.give_items(WATER_CRYSTAL, 1)
        st.take_items(INNOCENCE_JEWEL, -1)
        st.exit_quest(false, true)
        html = event
      end
    else
      # [automatically added else]
    end

    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state!(pc)
      return get_no_quest_msg(pc)
    end

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "31537-01.htm" : "31537-13.html"
    when State::STARTED
      case st.cond
      when 1
        html = "31537-14.html"
      when 2
        if st.has_quest_items?(INNOCENCE_JEWEL)
          html = "31537-15.html"
        else
          html = "31537-14.html"
        end
      else
        # [automatically added else]
      end
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end

  def self.check_jewel_of_innocence(pc : L2PcInstance)
    st = pc.get_quest_state(self.class.simple_name)
    if st && st.cond?(1) && !st.has_quest_items?(INNOCENCE_JEWEL)
      if Rnd.rand(100) < 5
        st.give_items(INNOCENCE_JEWEL, 1)
        st.set_cond(2, true)
      end
    end
  end
end
