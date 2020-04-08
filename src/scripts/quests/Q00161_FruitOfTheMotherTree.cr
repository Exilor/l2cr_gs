class Scripts::Q00161_FruitOfTheMotherTree < Quest
  # NPCs
  private ANDELLIA = 30362
  private THALIA = 30371
  # Items
  private ANDELLRIAS_LETTER = 1036
  private MOTHERTREE_FRUIT = 1037
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(161, self.class.simple_name, "Fruit of the Mother Tree")

    add_start_npc(ANDELLIA)
    add_talk_id(ANDELLIA, THALIA)
    register_quest_items(ANDELLRIAS_LETTER, MOTHERTREE_FRUIT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    html = event
    case event
    when "30362-04.htm"
      st.start_quest
      st.give_items(ANDELLRIAS_LETTER, 1)
    when "30371-03.html"
    else
      html = nil
    end

    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when ANDELLIA
      case st.state
      when State::CREATED
        html = pc.race.elf? ? pc.level >= MIN_LEVEL ? "30362-03.htm" : "30362-02.htm" : "30362-01.htm"
      when State::STARTED
        if st.cond?(1)
          html = "30362-05.html"
        elsif st.cond?(2) && st.has_quest_items?(MOTHERTREE_FRUIT)
          st.give_adena(1000, true)
          st.add_exp_and_sp(1000, 0)
          st.exit_quest(false, true)
          html = "30362-06.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    when THALIA
      if st.started?
        if st.cond?(1) && st.has_quest_items?(ANDELLRIAS_LETTER)
          st.take_items(ANDELLRIAS_LETTER, -1)
          st.give_items(MOTHERTREE_FRUIT, 1)
          st.set_cond(2, true)
          html = "30371-01.html"
        elsif st.cond?(2) && st.has_quest_items?(MOTHERTREE_FRUIT)
          html = "30371-02.html"
        end
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end