class Quests::Q00116_BeyondTheHillsOfWinter < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    case event
    when "30535-02.htm"
      st.start_quest
      st.memo_state = 1
      htmltext = event
    when "30535-05.html"
      if st.memo_state?(1)
        st.memo_state = 2
        st.set_cond(2, true)
        st.give_items(SUPPLYING_GOODS, 1)
        htmltext = event
      end
    when "32052-02.html"
      if st.memo_state?(2)
        htmltext = event
      end
    when "MATERIAL"
      if st.memo_state?(2)
        st.reward_items(SOULSHOT_D, 1740)
        st.add_exp_and_sp(82792, 4981)
        st.exit_quest(false, true)
        htmltext = "32052-03.html"
      end
    when "ADENA"
      if st.memo_state?(2)
        st.give_adena(17387, true)
        st.add_exp_and_sp(82792, 4981)
        st.exit_quest(false, true)
        htmltext = "32052-03.html"
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::COMPLETED
      if npc.id == FILAUR
        htmltext = get_already_completed_msg(player)
      end
    when State::CREATED
      if npc.id == FILAUR
        htmltext = player.level >= MIN_LEVEL ? "30535-01.htm" : "30535-03.htm"
      end
    when State::STARTED
      case npc.id
      when FILAUR
        if st.memo_state?(1)
          htmltext = has_all_items?(player, true, THIEF_KEY, BANDAGE, ENERGY_STONE) ? "30535-04.html" : "30535-06.html"
        elsif st.memo_state?(2)
          htmltext = "30535-07.html"
        end
      when OBI
        if st.memo_state?(2) && st.has_quest_items?(SUPPLYING_GOODS)
          htmltext = "32052-01.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
