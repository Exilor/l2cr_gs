class Scripts:: Q00002_WhatWomenWant < Quest
  # NPCs
  private ARUJIEN = 30223
  private MIRABEL = 30146
  private HERBIEL = 30150
  private GREENIS = 30157
  # Items
  private ARUJIENS_LETTER1 = 1092
  private ARUJIENS_LETTER2 = 1093
  private ARUJIENS_LETTER3 = 1094
  private POETRY_BOOK = 689
  private GREENIS_LETTER = 693
  private EARRING = 113
  # Misc
  private MIN_LEVEL = 2

  def initialize
    super(2, self.class.simple_name, "What Women Want")

    add_start_npc(ARUJIEN)
    add_talk_id(ARUJIEN, MIRABEL, HERBIEL, GREENIS)
    register_quest_items(
      ARUJIENS_LETTER1, ARUJIENS_LETTER2, ARUJIENS_LETTER3, POETRY_BOOK,
      GREENIS_LETTER
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case html = event
    when "30223-04.htm"
      st.start_quest
      give_items(pc, ARUJIENS_LETTER1, 1)
    when "30223-08.html"
      take_items(pc, ARUJIENS_LETTER3, -1)
      give_items(pc, POETRY_BOOK, 1)
      st.set_cond(4, true)
    when "30223-09.html"
      give_adena(pc, 450, true)
      st.exit_quest(false, true)
      show_on_screen_msg(pc, NpcString::DELIVERY_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE, 2, 5000)
      add_exp_and_sp(pc, 4254, 335)
      give_adena(pc, 1850, true)
    when "30223-03.html"
      # do nothing
    else
      html = nil
    end

    html
  end

  def on_talk(npc, pc)
    return unless st = get_quest_state(pc, true)

    case npc.id
    when ARUJIEN
      case st.state
      when State::CREATED
        if !pc.race.elf? && !pc.race.human?
          html = "30223-00.htm"
        else
          if pc.level >= MIN_LEVEL
            html = "30223-02.htm"
          else
            html = "30223-01.html"
          end
        end
      when State::STARTED
        case st.cond
        when 1
          html = "30223-05.html"
        when 2
          html = "30223-06.html"
        when 3
          html = "30223-07.html"
        when 4
          html = "30223-10.html"
        when 5
          give_items(pc, EARRING, 1)
          st.exit_quest(false, true)
          html = "30223-11.html"
          show_on_screen_msg(pc, NpcString::DELIVERY_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE, 2, 5000)
          add_exp_and_sp(pc, 4254, 335)
          give_adena(pc, 1850, true)
        else
          # automatically added
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    when MIRABEL
      if st.started?
        if st.cond?(1)
          st.set_cond(2, true)
          take_items(pc, ARUJIENS_LETTER1, -1)
          give_items(pc, ARUJIENS_LETTER2, 1)
          html = "30146-01.html"
        else
          html = "30146-02.html"
        end
      end
    when HERBIEL
      if st.started? && st.cond > 1
        if st.cond?(2)
          st.set_cond(3, true)
          take_items(pc, ARUJIENS_LETTER2, -1)
          give_items(pc, ARUJIENS_LETTER3, 1)
          html = "30150-01.html"
        else
          html = "30150-02.html"
        end
      end
    when GREENIS
      if st.started?
        if st.cond?(4)
          st.set_cond(5, true)
          take_items(pc, POETRY_BOOK, -1)
          give_items(pc, GREENIS_LETTER, 1)
          html = "30157-02.html"
        elsif st.cond?(5)
          html = "30157-03.html"
        else
          html = "30157-01.html"
        end
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end