class Scripts::Q10296_SevenSignsOneWhoSeeksThePowerOfTheSeal < Quest
  # NPCs
  private HARDIN = 30832
  private WOOD = 32593
  private FRANZ = 32597
  private ELCADIA = 32784
  private ELCADIA_2 = 32787
  private ERISS_EVIL_THOUGHTS = 32792
  private ODD_GLOBE = 32815
  # Reward
  private CERTIFICATE_OF_DAWN = 17265
  # Misc
  private MIN_LEVEL = 81

  def initialize
    super(10296, self.class.simple_name, "Seven Signs, One Who Seeks the Power of the Seal")

    add_start_npc(ERISS_EVIL_THOUGHTS, ODD_GLOBE)
    add_talk_id(
      ERISS_EVIL_THOUGHTS, ODD_GLOBE, HARDIN, WOOD, FRANZ, ELCADIA, ELCADIA_2
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "32792-02.htm"
      html = event
    when "32792-03.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "30832-03.html"
      if st.memo_state?(4)
        html = event
      end
    when "30832-04.html"
      if st.memo_state?(4)
        st.memo_state = 5
        st.set_cond(5, true)
        html = event
      end
    when "32593-03.html"
      if st.memo_state?(5)
        html = event
      end
    when "32597-02.html"
      if st.memo_state?(5)
        html = event
      end
    when "32597-03.html"
      if st.memo_state?(5)
        if pc.subclass_active?
          html = event
        else
          add_exp_and_sp(pc, 125_000_000, 12_500_000)
          give_items(pc, CERTIFICATE_OF_DAWN, 1)
          st.exit_quest(false, true)
          html = "32597-04.html"
        end
      end
    when "32784-02.html"
      if st.memo_state?(3)
        html = event
      end
    when "32784-03.html"
      if st.memo_state?(3)
        st.memo_state = 4
        st.set_cond(4, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == ERISS_EVIL_THOUGHTS
        html = "32792-04.html"
      end
    elsif st.created?
      if pc.quest_completed?(Q10295_SevenSignsSolinasTomb.simple_name)
        if npc.id == ERISS_EVIL_THOUGHTS && pc.level >= MIN_LEVEL
          html = "32792-01.htm"
        else
          html = "32815-01.html"
        end
      end
    elsif st.started?
      case npc.id
      when ERISS_EVIL_THOUGHTS
        if st.memo_state?(1)
          st.memo_state = 2
          st.set_cond(2, true)
          html = "32792-05.html"
        elsif st.memo_state?(2)
          html = "32792-06.html"
        end
      when ODD_GLOBE
        memo_state = st.memo_state
        if memo_state > 0 && memo_state <= 2
          html = "32815-01.html"
        elsif memo_state > 2
          html = "32815-02.html"
        end
      when HARDIN
        memo_state = st.memo_state
        if memo_state < 4
          html = "30832-01.html"
        elsif memo_state == 4
          html = "30832-02.html"
        elsif memo_state > 4
          html = "30832-04.html"
        end
      when WOOD
        memo_state = st.memo_state
        if memo_state < 5
          html = "32593-01.html"
        elsif memo_state == 5
          html = "32593-02.html"
        elsif memo_state > 5
          html = "32593-04.html"
        end
      when FRANZ
        if st.memo_state?(5)
          html = "32597-01.html"
        end
      when ELCADIA
        memo_state = st.memo_state
        if memo_state == 3
          html = "32784-01.html"
        elsif memo_state > 3
          html = "32784-04.html"
        end
      when ELCADIA_2
        memo_state = st.memo_state
        if memo_state < 1
          html = "32787-01.html"
        elsif memo_state < 2
          html = "32787-02.html"
        elsif memo_state == 2
          html = "32787-03.html"
        else
          st.set_cond(3, true)
          html = "32787-04.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
