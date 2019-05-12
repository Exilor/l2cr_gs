class Scripts::Q00261_CollectorsDream < Quest
  # Npc
  private ALSHUPES = 30222
  # Monsters
  private MONSTERS = {
    20308, # Hook Spider
    20460, # Crimson Spider
    20466  # Pincer Spider
  }
  # Item
  private SPIDER_LEG = 1087
  # Misc
  private MIN_LVL = 15
  private MAX_LEG_COUNT = 8
  # Message
  private MESSAGE = ExShowScreenMessage.new(NpcString::LAST_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE, 2, 5000)

  def initialize
    super(261, self.class.simple_name, "Collector's Dream")

    add_start_npc(ALSHUPES)
    add_talk_id(ALSHUPES)
    add_kill_id(MONSTERS)
    register_quest_items(SPIDER_LEG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30222-03.htm"
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, killer, true)
      if st.give_item_randomly(SPIDER_LEG, 1, MAX_LEG_COUNT, 1, true)
        st.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "30222-02.htm" : "30222-01.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "30222-04.html"
      when 2
        if st.get_quest_items_count(SPIDER_LEG) >= MAX_LEG_COUNT
          self.class.give_newbie_reward(pc)
          st.give_adena(1000, true)
          st.add_exp_and_sp(2000, 0)
          st.exit_quest(true, true)
          html = "30222-05.html"
        end
      end
    end

    html
  end

  def self.give_newbie_reward(pc : L2PcInstance)
    vars = pc.variables
    if vars["GUIDE_MISSION"]?.nil?
      vars["GUIDE_MISSION"] = 100000
      pc.send_packet(MESSAGE)
    elsif (vars.get_i32("GUIDE_MISSION") % 100000000) / 10000000 != 1
      vars["GUIDE_MISSION"] =  vars.get_i32("GUIDE_MISSION") + 10000000
      pc.send_packet(MESSAGE)
    end
  end
end
