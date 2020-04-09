class Scripts::Q00451_LuciensAltar < Quest
  # NPCs
  private DAICHIR = 30537
  private ALTARS = {
    32706,
    32707,
    32708,
    32709,
    32710
  }

  # Items
  private REPLENISHED_BEAD = 14877
  private DISCHARGED_BEAD = 14878
  # Misc
  private MIN_LEVEL = 80

  def initialize
    super(451, self.class.simple_name, "Lucien's Altar")

    add_start_npc(DAICHIR)
    add_talk_id(ALTARS)
    add_talk_id(DAICHIR)
    register_quest_items(REPLENISHED_BEAD, DISCHARGED_BEAD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event == "30537-04.htm"
      html = event
    elsif event == "30537-05.htm"
      st.start_quest
      st.give_items(REPLENISHED_BEAD, 5)
      html = event
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    npc_id = npc.id
    if npc_id == DAICHIR
      case st.state
      when State::COMPLETED
        unless st.now_available?
          html = "30537-03.html"
        end
        st.state = State::CREATED
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30537-01.htm" : "30537-02.htm"
      when State::STARTED
        if st.cond?(1)
          if st.set?("32706") || st.set?("32707") || st.set?("32708") || st.set?("32709") || st.set?("32710")
            html = "30537-10.html"
          else
            html = "30537-09.html"
          end
        else
          st.give_adena(255380, true) # Tauti reward: 13 773 960 exp, 16 232 820 sp, 742 800 Adena
          st.exit_quest(QuestType::DAILY, true)
          html = "30537-08.html"
        end
      else
        # [automatically added else]
      end

    elsif st.cond?(1) && st.has_quest_items?(REPLENISHED_BEAD)
      npc_id_str = npc_id.to_s
      if st.get_int(npc_id_str) == 0
        st.set(npc_id_str, "1")
        st.take_items(REPLENISHED_BEAD, 1)
        st.give_items(DISCHARGED_BEAD, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)

        if st.get_quest_items_count(DISCHARGED_BEAD) >= 5
          st.set_cond(2, true)
        end

        html = "recharge.html"
      else
        html = "findother.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
