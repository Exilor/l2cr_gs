class Scripts::Q00112_WalkOfFate < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    return if pc.level < MIN_LEVEL
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30572-04.htm"
      st.start_quest
      html = event
    when "32017-02.html"
      st.give_adena(22308, true)
      st.add_exp_and_sp(112876, 5774)
      st.give_items(SCROLL_ENCHANT_ARMOR_D_GRADE, 1)
      st.exit_quest(false, true)
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level < MIN_LEVEL ? "30572-03.html" : "30572-01.htm"
    when State::STARTED
      case npc.id
      when LIVINA
        html = "30572-05.html"
      when KARUDA
        html = "32017-01.html"
      else
        # [automatically added else]
      end

    when State::COMPLETED
      html = get_already_completed_msg(pc)
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
