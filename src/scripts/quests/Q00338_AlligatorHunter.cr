class Scripts::Q00338_AlligatorHunter < Quest
  # NPC
  private ENVERUN = 30892
  # Monster
  private ALLIGATOR = 20135
  # Items
  private ALLIGATOR_LEATHER = 4337
  # Misc
  private MIN_LEVEL = 40
  private SECOND_CHANCE = 19

  def initialize
    super(338, self.class.simple_name, "Alligator Hunter")

    add_start_npc(ENVERUN)
    add_talk_id(ENVERUN)
    add_kill_id(ALLIGATOR)
    register_quest_items(ALLIGATOR_LEATHER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30892-03.htm"
      st.start_quest
    when "30892-06.html"
      unless st.has_quest_items?(ALLIGATOR_LEATHER)
        return "30892-05.html"
      end
      amount = st.get_quest_items_count(ALLIGATOR_LEATHER) >= 10 ? 3430 : 0
      amount += 60 * st.get_quest_items_count(ALLIGATOR_LEATHER)
      st.give_adena(amount, true)
      st.take_items(ALLIGATOR_LEATHER, -1)
    when "30892-10.html"
      st.exit_quest(true, true)
    when "30892-07.html", "30892-08.html", "30892-09.html"
      # do nothing
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if st = get_quest_state(pc, false)
      st.give_items(ALLIGATOR_LEATHER, 1)
      if Rnd.rand(100) < SECOND_CHANCE
        st.give_items(ALLIGATOR_LEATHER, 1)
      end
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30892-02.htm" : "30892-01.htm"
    when State::STARTED
      html = "30892-04.html"
    end


    html || get_no_quest_msg(pc)
  end
end
