class Quests::Q00017_LightAndDarkness < Quest
  # NPCs
  private HIERARCH = 31517
  private SAINT_ALTAR_1 = 31508
  private SAINT_ALTAR_2 = 31509
  private SAINT_ALTAR_3 = 31510
  private SAINT_ALTAR_4 = 31511
  # Item
  private BLOOD_OF_SAINT = 7168

  def initialize
    super(17, self.class.simple_name, "Light and Darkness")

    add_start_npc(HIERARCH)
    add_talk_id(HIERARCH, SAINT_ALTAR_1, SAINT_ALTAR_2, SAINT_ALTAR_3, SAINT_ALTAR_4)
    register_quest_items(BLOOD_OF_SAINT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    st = get_quest_state(player, false)
    unless st
      return htmltext
    end

    case event
    when "31517-02.html"
      if player.level >= 61
        st.start_quest
        st.give_items(BLOOD_OF_SAINT, 4)
      else
        htmltext = "31517-02a.html"
      end
    when "31508-02.html", "31509-02.html", "31510-02.html", "31511-02.html"
      cond = st.cond
      npc_id = event.to_i
      if cond == npc_id - 31507 && st.has_quest_items?(BLOOD_OF_SAINT)
        htmltext = "#{npc_id}-01.html"
        st.take_items(BLOOD_OF_SAINT, 1)
        st.set_cond(cond + 1, true)
      end
    end
    return htmltext
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state!(player)

    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if player.quest_completed?(Q00015_SweetWhispers.simple_name)
        htmltext = "31517-00.htm"
      else
        htmltext = "31517-06.html"
      end
    when State::STARTED
      blood = st.get_quest_items_count(BLOOD_OF_SAINT)
      npc_id = npc.id
      case npc_id
      when HIERARCH
        if st.cond < 5
          htmltext = blood >= 5 ? "31517-05.html" : "31517-04.html"
        else
          st.add_exp_and_sp(697040, 54887)
          st.exit_quest(false, true)
          htmltext = "31517-03.html"
        end
      when SAINT_ALTAR_1, SAINT_ALTAR_2, SAINT_ALTAR_3, SAINT_ALTAR_4
        if npc_id - 31507 == st.cond
          htmltext = npc_id.to_s + ((blood > 0) ? "-00.html" : "-02.html")
        elsif st.cond > npc_id - 31507
          htmltext = npc_id.to_s + "-03.html"
        end
      end
    end

    htmltext
  end
end
