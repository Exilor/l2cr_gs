class Scripts::Q00195_SevenSignsSecretRitualOfThePriests < Quest
  # NPCs
  private RAYMOND = 30289
  private IASON_HEINE = 30969
  private CLAUDIA_ATHEBALDT = 31001
  private LIGHT_OF_DAWN = 32575
  private JOHN = 32576
  private PASSWORD_ENTRY_DEVICE = 32577
  private IDENTITY_CONFIRM_DEVICE = 32578
  private DARKNESS_OF_DAWN = 32579
  private SHELF = 32580
  # Items
  private IDENTITY_CARD = 13822
  private SHUNAIMANS_CONTRACT = 13823
  # Misc
  private MIN_LEVEL = 79
  # Skills
  # private static SkillHolder TRANSFORM_DISPEL = SkillHolder.new(6200)
  private TRANSFORMATION = SkillHolder.new(6204)

  def initialize
    super(195, self.class.simple_name, "Seven Signs, Secret Ritual of the Priests")

    add_first_talk_id(
      IDENTITY_CONFIRM_DEVICE, PASSWORD_ENTRY_DEVICE, DARKNESS_OF_DAWN, SHELF
    )
    add_start_npc(CLAUDIA_ATHEBALDT)
    add_talk_id(
      CLAUDIA_ATHEBALDT, JOHN, RAYMOND, IASON_HEINE, LIGHT_OF_DAWN,
      DARKNESS_OF_DAWN, IDENTITY_CONFIRM_DEVICE, PASSWORD_ENTRY_DEVICE, SHELF
    )
    register_quest_items(IDENTITY_CARD, SHUNAIMANS_CONTRACT)
  end

  def on_adv_event(event, npc, pc)
    debug "#on_adv_event(#{event}, #{npc}, #{pc})"
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    npc = npc.not_nil!

    case event
    when "31001-03.html", "31001-04.html", "31001-05.html", "32580-03.html"
      html = event
    when "31001-06.html"
      st.start_quest
      html = event
    when "32576-02.html"
      if st.cond?(1)
        st.give_items(IDENTITY_CARD, 1)
        st.set_cond(2, true)
        html = event
      end
    when "30289-02.html", "30289-03.html", "30289-05.html"
      if st.cond?(2)
        html = event
      end
    when "30289-04.html"
      if st.cond?(2)
        npc.target = pc
        npc.do_cast(TRANSFORMATION)
        st.set_cond(3, true)
        html = event
      end
    when "30289-07.html"
      if st.cond?(3)
        html = event
      end
    when "30289-08.html"
      if st.cond?(3) && st.has_quest_items?(IDENTITY_CARD)
        if st.has_quest_items?(SHUNAIMANS_CONTRACT)
          st.take_items(IDENTITY_CARD, -1)
          st.set_cond(4, true)
          html = event
          if pc.transformation_id == 113
            # pc.do_cast(TRANSFORM_DISPEL)
            pc.stop_all_effects
          end
        end
      end
    when "30289-10.html"
      if st.cond?(3)
        npc.target = pc
        npc.do_cast(TRANSFORMATION)
        html = event
      end
    when "30289-11.html"
      if st.cond?(3)
        # pc.do_cast(TRANSFORM_DISPEL)
        pc.stop_all_effects
        html = event
      end
    when "30969-02.html"
      if st.cond?(4) && st.has_quest_items?(SHUNAIMANS_CONTRACT)
        html = event
      end
    when "reward"
      if st.cond?(4) && st.has_quest_items?(SHUNAIMANS_CONTRACT)
        if pc.level >= MIN_LEVEL
          st.add_exp_and_sp(52518015, 5817677)
          st.exit_quest(false, true)
          html = "30969-03.html"
        else
          html = "level_check.html"
        end
      end
    else
      # automatically added
    end


    html
  end

  def on_first_talk(npc, pc)
    case npc.id
    when IDENTITY_CONFIRM_DEVICE
      "32578-01.html"
    when PASSWORD_ENTRY_DEVICE
      "32577-01.html"
    when DARKNESS_OF_DAWN
      "32579-01.html"
    when SHELF
      "32580-01.html"
    else
      # automatically added
    end

  end

  def on_talk(npc, pc)
    debug "#on_talk(#{npc}, #{pc})"
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == CLAUDIA_ATHEBALDT
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00194_SevenSignsMammonsContract.simple_name)
          html = "31001-01.htm"
        else
          html = "31001-02.html"
        end
      end
    when State::STARTED
      case npc.id
      when CLAUDIA_ATHEBALDT
        if st.cond?(1)
          html = "31001-07.html"
        end
      when JOHN
        case st.cond
        when 1
          html = "32576-01.html"
        when 2
          html = "32576-03.html"
        else
          # automatically added
        end

      when RAYMOND
        case st.cond
        when 2
          if st.has_quest_items?(IDENTITY_CARD)
            if pc.transformation_id != 113
              html = "30289-01.html"
            end
          end
        when 3
          if st.has_quest_items?(IDENTITY_CARD)
            if st.has_quest_items?(SHUNAIMANS_CONTRACT)
              html = "30289-06.html"
            else
              html = "30289-09.html"
            end
          end
        when 4
          html = "30289-12.html"
        else
          # automatically added
        end

      when LIGHT_OF_DAWN
        if st.cond?(3)
          if st.has_quest_items?(IDENTITY_CARD)
            html = "31001-07.html"
          end
        end
      when PASSWORD_ENTRY_DEVICE
        if st.cond?(3) && st.has_quest_items?(IDENTITY_CARD)
          html = "32577-02.html"
          pc.tele_to_location(-78240, 205858, -7856)
        end
      when SHELF
        if st.cond?(3) && !st.has_quest_items?(SHUNAIMANS_CONTRACT)
          st.give_items(SHUNAIMANS_CONTRACT, 1)
          html = "32580-02.html"
        end
      when DARKNESS_OF_DAWN
        if st.cond?(3) && !st.has_quest_items?(SHUNAIMANS_CONTRACT)
          html = "32579-02.html"
        end
      when IASON_HEINE
        if st.cond?(4) && st.has_quest_items?(SHUNAIMANS_CONTRACT)
          html = "30969-01.html"
        end
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end