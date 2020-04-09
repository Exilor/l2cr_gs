class Scripts::Q00364_JovialAccordion < Quest
  # NPCs
  private SABRIN = 30060
  private XABER = 30075
  private SWAN = 30957
  private BARBADO = 30959
  private BEER_CHEST = 30960
  private CLOTH_CHEST = 30961
  # Items
  private STOLEN_BLACK_BEER = 4321
  private STOLEN_EVENT_CLOTHES = 4322
  private CLOTHES_CHEST_KEY = 4323
  private BEER_CHEST_KEY = 4324
  private THEME_OF_THE_FEAST = 4421
  # Misc
  private MIN_LEVEL = 15

  def initialize
    super(364, self.class.simple_name, "Jovial Accordion")

    add_start_npc(BARBADO)
    add_talk_id(BARBADO, BEER_CHEST, CLOTH_CHEST, SABRIN, XABER, SWAN)
    register_quest_items(
      STOLEN_BLACK_BEER, STOLEN_EVENT_CLOTHES, CLOTHES_CHEST_KEY, BEER_CHEST_KEY
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "START"
      if pc.level >= MIN_LEVEL
        st.start_quest
        st.memo_state = 1
        html = "30959-02.htm"
      else
        html = "30959-03.htm"
      end
    when "OPEN_CHEST"
      if st.has_quest_items?(BEER_CHEST_KEY)
        if Rnd.bool
          st.give_items(STOLEN_BLACK_BEER, 1)
          html = "30960-02.html"
        else
          html = "30960-03.html"
        end
        st.take_items(BEER_CHEST_KEY, -1)
      else
        html = "30960-04.html"
      end
    when "OPEN_CLOTH_CHEST"
      if st.has_quest_items?(CLOTHES_CHEST_KEY)
        if Rnd.bool
          st.give_items(STOLEN_EVENT_CLOTHES, 1)
          html = "30961-02.html"
        else
          html = "30961-03.html"
        end
        st.take_items(CLOTHES_CHEST_KEY, -1)
      else
        html = "30961-04.html"
      end
    when "30957-02.html"
      st.give_items(CLOTHES_CHEST_KEY, 1)
      st.give_items(BEER_CHEST_KEY, 1)
      st.memo_state = 2
      st.set_cond(2, true)
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
      if npc.id == BARBADO
        html = "30959-01.htm"
      end
    when State::STARTED
      case npc.id
      when BARBADO
        case st.memo_state
        when 1..4
          html = "30959-04.html"
        when 5
          st.reward_items(THEME_OF_THE_FEAST, 1)
          st.exit_quest(true, true)
          html = "30959-05.html"
        else
          # [automatically added else]
        end

      when BEER_CHEST
        html = "30960-01.html"
      when CLOTH_CHEST
        html = "30961-01.html"
      when SABRIN
        if st.has_quest_items?(STOLEN_BLACK_BEER)
          st.take_items(STOLEN_BLACK_BEER, -1)
          html = "30060-01.html"
          if st.memo_state?(2)
            st.memo_state = 3
          elsif st.memo_state?(3)
            st.memo_state = 4
          end
        else
          html = "30060-02.html"
        end
      when XABER
        if st.has_quest_items?(STOLEN_EVENT_CLOTHES)
          st.take_items(STOLEN_EVENT_CLOTHES, -1)
          html = "30075-01.html"
          if st.memo_state?(2)
            st.memo_state = 3
          elsif st.memo_state?(3)
            st.memo_state = 4
          end
        else
          html = "30075-02.html"
        end
      when SWAN
        case st.memo_state
        when 1
          html = "30957-01.html"
        when 2, 3
          if has_at_least_one_quest_item?(pc, BEER_CHEST_KEY, CLOTHES_CHEST_KEY, STOLEN_BLACK_BEER, STOLEN_EVENT_CLOTHES)
            html = "30957-03.html"
          elsif !st.has_quest_items?(BEER_CHEST_KEY, CLOTHES_CHEST_KEY, STOLEN_BLACK_BEER, STOLEN_EVENT_CLOTHES)
            if st.memo_state?(2)
              st.play_sound(Sound::ITEMSOUND_QUEST_GIVEUP)
              st.exit_quest(true, true)
              html = "30957-06.html"
            else
              st.memo_state = 5
              st.set_cond(3, true)
              html = "30957-04.html"
            end
          end
        when 4
          unless st.has_quest_items?(BEER_CHEST_KEY, CLOTHES_CHEST_KEY, STOLEN_BLACK_BEER, STOLEN_EVENT_CLOTHES)
            st.memo_state = 5
            st.set_cond(3, true)
            st.give_adena(100, true)
            html = "30957-05.html"
          end
        when 5
          html = "30957-07.html"
        else
          # [automatically added else]
        end

      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
