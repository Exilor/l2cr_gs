class Scripts::Q00116_BeyondTheHillsOfWinter < Quest
  # NPCs
  private FILAUR = 30535
  private OBI = 32052
  # Items
  private THIEF_KEY = ItemHolder.new(1661, 10)
  private BANDAGE = ItemHolder.new(1833, 20)
  private ENERGY_STONE = ItemHolder.new(5589, 5)
  private SUPPLYING_GOODS = 8098
  # Reward
  private SOULSHOT_D = 1463
  # Misc
  private MIN_LEVEL = 30

  def initialize
    super(116, self.class.simple_name, "Beyond the Hills of Winter")

    add_start_npc(FILAUR)
    add_talk_id(FILAUR, OBI)
    register_quest_items(SUPPLYING_GOODS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30535-02.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "30535-05.html"
      if st.memo_state?(1)
        st.memo_state = 2
        st.set_cond(2, true)
        st.give_items(SUPPLYING_GOODS, 1)
        html = event
      end
    when "32052-02.html"
      if st.memo_state?(2)
        html = event
      end
    when "MATERIAL"
      if st.memo_state?(2)
        st.reward_items(SOULSHOT_D, 1740)
        st.add_exp_and_sp(82792, 4981)
        st.exit_quest(false, true)
        html = "32052-03.html"
      end
    when "ADENA"
      if st.memo_state?(2)
        st.give_adena(17387, true)
        st.add_exp_and_sp(82792, 4981)
        st.exit_quest(false, true)
        html = "32052-03.html"
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      if npc.id == FILAUR
        html = get_already_completed_msg(pc)
      end
    when State::CREATED
      if npc.id == FILAUR
        html = pc.level >= MIN_LEVEL ? "30535-01.htm" : "30535-03.htm"
      end
    when State::STARTED
      case npc.id
      when FILAUR
        if st.memo_state?(1)
          if has_all_items?(pc, true, THIEF_KEY, BANDAGE, ENERGY_STONE)
            html = "30535-04.html"
          else
            html = "30535-06.html"
          end
        elsif st.memo_state?(2)
          html = "30535-07.html"
        end
      when OBI
        if st.memo_state?(2) && st.has_quest_items?(SUPPLYING_GOODS)
          html = "32052-01.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
