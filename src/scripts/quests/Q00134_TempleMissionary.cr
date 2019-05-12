class Scripts::Q00134_TempleMissionary < Quest
  # NPCs
  private GLYVKA = 30067
  private ROUKE = 31418
  # Items
  private GIANTS_EXPERIMENTAL_TOOL_FRAGMENT = 10335
  private GIANTS_EXPERIMENTAL_TOOL = 10336
  private GIANTS_TECHNOLOGY_REPORT = 10337
  private ROUKES_REPOT = 10338
  private BADGE_TEMPLE_MISSIONARY = 10339
  # Monsters
  private CRUMA_MARSHLANDS_TRAITOR = 27339
  private MOBS = {
    20157 => 78, # Marsh Stakato
    20229 => 75, # Stinger Wasp
    20230 => 86, # Marsh Stakato Worker
    20231 => 83, # Toad Lord
    20232 => 81, # Marsh Stakato Soldier
    20233 => 95, # Marsh Spider
    20234 => 96  # Marsh Stakato Drone
  }
  # Misc
  private MIN_LEVEL = 35
  private MAX_REWARD_LEVEL = 41
  private FRAGMENT_COUNT = 10
  private REPORT_COUNT = 3

  def initialize
    super(134, self.class.simple_name, "Temple Missionary")

    add_start_npc(GLYVKA)
    add_talk_id(GLYVKA, ROUKE)
    add_kill_id(CRUMA_MARSHLANDS_TRAITOR)
    add_kill_id(MOBS.keys)
    register_quest_items(
      GIANTS_EXPERIMENTAL_TOOL_FRAGMENT, GIANTS_EXPERIMENTAL_TOOL,
      GIANTS_TECHNOLOGY_REPORT, ROUKES_REPOT
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30067-05.html", "30067-09.html", "31418-07.html", "30067-03.htm"
      st.start_quest
    when "30067-06.html"
      st.set_cond(2, true)
    when "31418-03.html"
      st.set_cond(3, true)
    when "31418-08.html"
      st.set_cond(5, true)
      st.give_items(ROUKES_REPOT, 1)
      st.unset("talk")
    when "30067-10.html"
      st.give_items(BADGE_TEMPLE_MISSIONARY, 1)
      st.give_adena(15100, true)
      if pc.level < MAX_REWARD_LEVEL
        st.add_exp_and_sp(30000, 2000)
      end
      st.exit_quest(false, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 3)
      return super
    end

    st = get_quest_state(member, false).not_nil!
    if npc.id == CRUMA_MARSHLANDS_TRAITOR
      st.give_items(GIANTS_TECHNOLOGY_REPORT, 1)
      if st.get_quest_items_count(GIANTS_TECHNOLOGY_REPORT) >= REPORT_COUNT
        st.set_cond(4, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    else
      if st.has_quest_items?(GIANTS_EXPERIMENTAL_TOOL)
        st.take_items(GIANTS_EXPERIMENTAL_TOOL, 1)
        if Rnd.rand(100) != 0
          add_spawn(CRUMA_MARSHLANDS_TRAITOR, npc.x + 20, npc.y + 20, npc.z, npc.heading, false, 60000)
        end
      elsif Rnd.rand(100) < MOBS[npc.id]
        st.give_items(GIANTS_EXPERIMENTAL_TOOL_FRAGMENT, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when GLYVKA
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30067-01.htm" : "30067-02.htm"
      when State::STARTED
        case st.cond
        when 1
          html = "30067-04.html"
        when 2..4
          html = "30067-07.html"
        when 5
          if st.set?("talk")
            html = "30067-09.html"
          else
            st.take_items(ROUKES_REPOT, -1)
            st.set("talk", "1")
            html = "30067-08.html"
          end
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when ROUKE
      if st.started?
        case st.cond
        when 1
          html = "31418-01.html"
        when 2
          html = "31418-02.html"
        when 3
          if st.get_quest_items_count(GIANTS_EXPERIMENTAL_TOOL_FRAGMENT) < FRAGMENT_COUNT && st.get_quest_items_count(GIANTS_TECHNOLOGY_REPORT) < REPORT_COUNT
            html = "31418-04.html"
          elsif st.get_quest_items_count(GIANTS_EXPERIMENTAL_TOOL_FRAGMENT) >= FRAGMENT_COUNT
            count = st.get_quest_items_count(GIANTS_EXPERIMENTAL_TOOL_FRAGMENT) / 10
            st.take_items(GIANTS_EXPERIMENTAL_TOOL_FRAGMENT, count * 10)
            st.give_items(GIANTS_EXPERIMENTAL_TOOL, count)
            html = "31418-05.html"
          end
        when 4
          if st.set?("talk")
            html = "31418-07.html"
          elsif st.get_quest_items_count(GIANTS_TECHNOLOGY_REPORT) >= REPORT_COUNT
            st.take_items(GIANTS_EXPERIMENTAL_TOOL_FRAGMENT, -1)
            st.take_items(GIANTS_EXPERIMENTAL_TOOL, -1)
            st.take_items(GIANTS_TECHNOLOGY_REPORT, -1)
            st.set("talk", "1")
            html = "31418-06.html"
          end
        when 5
          html = "31418-09.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
