class Scripts::Q10501_ZakenEmbroideredSoulCloak < Quest
  # NPC
  private OLF_ADAMS = 32612
  # Monster
  private ZAKEN = 29181
  # Items
  private ZAKENS_SOUL_FRAGMENT = 21722
  private SOUL_CLOAK_OF_ZAKEN = 21719
  # Misc
  private MIN_LEVEL = 78
  private FRAGMENT_COUNT = 20

  def initialize
    super(10501, self.class.simple_name, "Zaken Embroidered Soul Cloak")

    add_start_npc(OLF_ADAMS)
    add_talk_id(OLF_ADAMS)
    add_kill_id(ZAKEN)
    register_quest_items(ZAKENS_SOUL_FRAGMENT)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, pc, false)
      current_count = get_quest_items_count(pc, ZAKENS_SOUL_FRAGMENT)
      count = Rnd.rand(1..3)
      if count >= FRAGMENT_COUNT &- current_count
        give_items(pc, ZAKENS_SOUL_FRAGMENT, FRAGMENT_COUNT &- current_count)
        st.set_cond(2, true)
      else
        give_items(pc, ZAKENS_SOUL_FRAGMENT, count)
        play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && pc.level >= MIN_LEVEL && event == "32612-04.html"
      st.start_quest
      return event
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, true)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level < MIN_LEVEL ? "32612-02.html" : "32612-01.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "32612-05.html"
      when 2
        if get_quest_items_count(pc, ZAKENS_SOUL_FRAGMENT) >= FRAGMENT_COUNT
          give_items(pc, SOUL_CLOAK_OF_ZAKEN, 1)
          play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
          st.exit_quest(false, true)
          html = "32612-06.html"
        end
      end
    when State::COMPLETED
      html = "32612-03.html"
    end

    html || get_no_quest_msg(pc)
  end
end
