class Quests::Q00112_WalkOfFate < Quest
  # NPCs
  private LIVINA = 30572
  private KARUDA = 32017
  # Item
  private SCROLL_ENCHANT_ARMOR_D_GRADE = 956
  # Misc
  private MIN_LEVEL = 20

  def initialize
    super(112, self.class.simple_name, "Walk of Fate")

    add_start_npc(LIVINA)
    add_talk_id(LIVINA, KARUDA)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return if player.level < MIN_LEVEL
    unless st = get_quest_state(player, false)
      return
    end

    case event
    when "30572-04.htm"
      st.start_quest
      htmltext = event
    when "32017-02.html"
      st.give_adena(22308, true)
      st.add_exp_and_sp(112876, 5774)
      st.give_items(SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
      st.exit_quest(false, true)
      htmltext = event
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    case st.state
    when State::CREATED
      htmltext = player.level < MIN_LEVEL ? "30572-03.html" : "30572-01.htm"
    when State::STARTED
      case npc.id
      when LIVINA
        htmltext = "30572-05.html"
      when KARUDA
        htmltext = "32017-01.html"
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    end

    htmltext
  end
end
