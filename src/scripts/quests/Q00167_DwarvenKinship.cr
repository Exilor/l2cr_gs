class Quests::Q00167_DwarvenKinship < Quest
  # NPCs
  private NORMAN = 30210
  private HAPROCK = 30255
  private CARLON = 30350
  # Items
  private CARLONS_LETTER = 1076
  private NORMANS_LETTER = 1106
  # Misc
  private MIN_LVL = 15

  def initialize
    super(167, self.class.simple_name, "Dwarven Kinship")

    add_start_npc(CARLON)
    add_talk_id(CARLON, NORMAN, HAPROCK)
    register_quest_items(CARLONS_LETTER, NORMANS_LETTER)
  end

  def on_adv_event(event, npc, player)
    return unless player
    st = get_quest_state(player, false)

    if st
      case event
      when "30210-02.html"
        if st.cond?(2) && st.has_quest_items?(NORMANS_LETTER)
          st.give_adena(20000, true)
          st.exit_quest(false, true)
          htmltext = event
        end
      when "30255-02.html"
        htmltext = event
      when "30255-03.html"
        if st.cond?(1) && st.has_quest_items?(CARLONS_LETTER)
          st.take_items(CARLONS_LETTER, -1)
          st.give_items(NORMANS_LETTER, 1)
          st.give_adena(2000, true)
          st.set_cond(2)
          htmltext = event
        end
      when "30255-04.html"
        if st.cond?(1) && st.has_quest_items?(CARLONS_LETTER)
          st.give_adena(15000, true)
          st.exit_quest(false, true)
          htmltext = event
        end
      when "30350-03.htm"
        st.start_quest
        st.give_items(CARLONS_LETTER, 1)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)

    if st
      case npc.id
      when CARLON
        case st.state
        when State::CREATED
          htmltext = player.level >= MIN_LVL ? "30350-02.htm" : "30350-01.htm"
        when State::STARTED
          if st.cond?(1) && st.has_quest_items?(CARLONS_LETTER)
            htmltext = "30350-04.html"
          end
        when State::COMPLETED
          htmltext = get_already_completed_msg(player)
        end
      when HAPROCK
        if st.cond?(1) && st.has_quest_items?(CARLONS_LETTER)
          htmltext = "30255-01.html"
        elsif st.cond?(2) && st.has_quest_items?(NORMANS_LETTER)
          htmltext = "30255-05.html"
        end
      when NORMAN
        if st.cond?(2) && st.has_quest_items?(NORMANS_LETTER)
          htmltext = "30210-01.html"
        end
      end
    end

    htmltext
  end
end
