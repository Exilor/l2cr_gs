class Quests::Q00174_SupplyCheck < Quest
  private MIN_LEVEL = 2
  # NPCs
	private NIKA = 32167
	private BENIS = 32170
	private MARCELA = 32173

	# Items
	private WAREHOUSE_MANIFEST = 9792
	private GROCERY_STORE_MANIFEST = 9793
	private REWARD = {
		23,   # Wooden Breastplate
		43,   # Wooden Helmet
		49,   # Gloves
		2386, # Wooden Gaiters
		37    # Leather Shoes
	}

  def initialize
    super(174, self.class.simple_name, "Supply Check")

    add_start_npc(MARCELA)
		add_talk_id(MARCELA, BENIS, NIKA)
		register_quest_items(WAREHOUSE_MANIFEST, GROCERY_STORE_MANIFEST)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    if st = get_quest_state(pc, false)
      if event.casecmp?("32173-03.htm")
        st.start_quest
        event
      end
    end
  end

  def on_talk(npc, pc)
    htmltext = get_no_quest_msg(pc)
    return htmltext unless st = get_quest_state(pc, true)

    case npc.id
    when MARCELA
      case st.state
      when State::CREATED
        htmltext = pc.level >= MIN_LEVEL ? "32173-01.htm" : "32173-02.htm"
      when State::STARTED
        case st.cond
        when 1
          htmltext = "32173-04.html"
        when 2
          st.set_cond(3, true)
          st.take_items(WAREHOUSE_MANIFEST, -1)
          htmltext = "32173-05.html"
        when 3
          htmltext = "32173-06.html"
        when 4
          REWARD.each { |item_id| st.give_items(item_id, 1) }
          st.give_adena(2466, true)
          st.add_exp_and_sp(5672, 446)
          st.exit_quest(false, true)
          msg = NpcString::DELIVERY_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE
          show_on_screen_msg(pc, msg, 2, 5000)
          htmltext = "32173-07.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(pc)
      end
    when BENIS
      if st.started?
        case st.cond
        when 1
          st.set_cond(2, true)
          st.give_items(WAREHOUSE_MANIFEST, 1)
          htmltext = "32170-01.html"
        when 2
          htmltext = "32170-02.html"
        when 3
          htmltext = "32170-03.html"
        end
      end
    when NIKA
      if st.started?
        case st.cond
        when 1, 2
          htmltext = "32167-01.html"
        when 3
          st.set_cond(4, true)
          st.give_items(GROCERY_STORE_MANIFEST, 1)
          htmltext = "32167-02.html"
        when 4
          htmltext = "32167-03.html"
        end
      end
    end

    htmltext
  end
end
