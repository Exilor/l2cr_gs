class Quests::Q00033_MakeAPairOfDressShoes < Quest
  # NPCs
  private IAN = 30164
  private WOODLEY = 30838
  private LEIKAR = 31520
  # Items
  private LEATHER = 1882
  private THREAD = 1868
  private DRESS_SHOES_BOX = 7113
  # Misc
  private MIN_LEVEL = 60
  private LEATHER_COUNT = 200
  private THREAD_COUNT = 600
  private ADENA_COUNT = 500000
  private ADENA_COUNT2 = 200000
  private ADENA_COUNT3 = 300000

  def initialize
    super(33, self.class.simple_name, "Make a Pair of Dress Shoes")

    add_start_npc(WOODLEY)
    add_talk_id(WOODLEY, IAN, LEIKAR)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    htmltext = event
    case event
    when "30838-03.htm"
      st.start_quest
    when "30838-06.html"
      st.set_cond(3, true)
    when "30838-09.html"
      if st.get_quest_items_count(LEATHER) >= LEATHER_COUNT && st.get_quest_items_count(THREAD) >= THREAD_COUNT && player.adena >= ADENA_COUNT2
        st.take_items(LEATHER, LEATHER_COUNT)
        st.take_items(THREAD, LEATHER_COUNT)
        st.take_items(Inventory::ADENA_ID, ADENA_COUNT2)
        st.set_cond(4, true)
      else
        htmltext = "30838-10.html"
      end
    when "30838-13.html"
      st.give_items(DRESS_SHOES_BOX, 1)
      st.exit_quest(false, true)
    when "31520-02.html"
      st.set_cond(2, true)
    when "30164-02.html"
      if player.adena < ADENA_COUNT3
        return "30164-03.html"
      end
      st.take_items(Inventory::ADENA_ID, ADENA_COUNT3)
      st.set_cond(5, true)
    else
      htmltext = nil
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    case npc.id
    when WOODLEY
      case st.state
      when State::CREATED
        htmltext = player.level >= MIN_LEVEL ? "30838-01.htm" : "30838-02.html"
      when State::STARTED
        case st.cond
        when 1
          htmltext = "30838-04.html"
        when 2
          htmltext = "30838-05.html"
        when 3
          if st.get_quest_items_count(LEATHER) >= LEATHER_COUNT && st.get_quest_items_count(THREAD) >= THREAD_COUNT && player.adena >= ADENA_COUNT
            htmltext = "30838-07.html"
          else
            htmltext = "30838-08.html"
          end
        when 4
          htmltext = "30838-11.html"
        when 5
          htmltext = "30838-12.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when LEIKAR
      if st.started?
        if st.cond?(1)
          htmltext = "31520-01.html"
        elsif st.cond?(2)
          htmltext = "31520-03.html"
        end
      end
    when IAN
      if st.started?
        if st.cond?(4)
          htmltext = "30164-01.html"
        elsif st.cond?(5)
          htmltext = "30164-04.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
