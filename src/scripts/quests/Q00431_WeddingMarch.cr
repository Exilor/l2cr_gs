class Scripts::Q00431_WeddingMarch < Quest
  # NPC
  private KANTABILON = 31042
  # Monsters
  private MOBS = {
    20786, # Lienrik
    20787  # Lienrik Lad
  }
  # Items
  private SILVER_CRYSTAL = 7540
  private WEDDING_ECHO_CRYSTAL = 7062
  # Misc
  private MIN_LEVEL = 38
  private CRYSTAL_COUNT = 50

  def initialize
    super(431, self.class.simple_name, "Wedding March")

    add_start_npc(KANTABILON)
    add_talk_id(KANTABILON)
    add_kill_id(MOBS)
    register_quest_items(SILVER_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event.casecmp?("31042-02.htm")
      st.start_quest
      html = event
    elsif event.casecmp?("31042-06.html")
      if st.get_quest_items_count(SILVER_CRYSTAL) < CRYSTAL_COUNT
        return "31042-05.html"
      end
      st.give_items(WEDDING_ECHO_CRYSTAL, 25)
      st.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if member = get_random_party_member(pc, 1)
      st = get_quest_state(member, false).not_nil!
      if Rnd.bool
        st.give_items(SILVER_CRYSTAL, 1)
        if st.get_quest_items_count(SILVER_CRYSTAL) >= CRYSTAL_COUNT
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "31042-01.htm" : "31042-00.htm"
    when State::STARTED
      html = st.cond?(1) ? "31042-03.html" : "31042-04.html"
    end

    html || get_no_quest_msg(pc)
  end
end
