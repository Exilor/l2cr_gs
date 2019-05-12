class Scripts::Q00240_ImTheOnlyOneYouCanTrust < Quest
  # NPC
  private KINTAIJIN = 32640
  # Monster
  private MOBS = {
    22617,
    22618,
    22619,
    22620,
    22621,
    22622,
    22623,
    22624,
    22625,
    22626,
    22627,
    22628,
    22629,
    22630,
    22631,
    22632,
    22633
  }
  # Item
  private STAKATO_FANG = 14879

  def initialize
    super(240, self.class.simple_name, "I'm the Only One You Can Trust")

    add_start_npc(KINTAIJIN)
    add_talk_id(KINTAIJIN)
    add_kill_id(MOBS)
    register_quest_items(STAKATO_FANG)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event.casecmp?("32640-3.htm")
      st.start_quest
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    unless m = get_random_party_member(pc, 1)
      return super
    end

    st = get_quest_state(m, false).not_nil!
    st.give_items(STAKATO_FANG, 1)
    if st.get_quest_items_count(STAKATO_FANG) >= 25
      st.set_cond(2, true)
    else
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level >= 81 ? "32640-1.htm" : "32640-0.htm"
    when State::STARTED
      case st.cond
      when 1
        if st.has_quest_items?(STAKATO_FANG)
          html = "32640-9.html"
        else
          html = "32640-8.html"
        end
      when 2
        if st.get_quest_items_count(STAKATO_FANG) >= 25
          st.give_adena(147200, true)
          st.take_items(STAKATO_FANG, -1)
          st.add_exp_and_sp(589542, 36800)
          st.exit_quest(false, true)
          html = "32640-10.html"
        end
      end
    when State::COMPLETED
      html = "32640-11.html"
    end

    html || get_no_quest_msg(pc)
  end
end
