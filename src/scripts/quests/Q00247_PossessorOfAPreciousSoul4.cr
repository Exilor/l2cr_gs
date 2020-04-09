class Scripts::Q00247_PossessorOfAPreciousSoul4 < Quest
  # NPCs
  private CARADINE = 31740
  private LADY_OF_LAKE = 31745
  # Items
  private CARADINE_LETTER_LAST = 7679
  private NOBLESS_TIARA = 7694
  # Location
  private CARADINE_LOC = Location.new(143209, 43968, -3038)
  # Skill
  private MIMIRS_ELIXIR = SkillHolder.new(4339)

  def initialize
    super(247, self.class.simple_name, "Possessor Of A Precious Soul 4")

    add_start_npc(CARADINE)
    add_talk_id(CARADINE, LADY_OF_LAKE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end
    unless pc.subclass_active?
      return "no_sub.html"
    end

    npc = npc.not_nil!

    case event
    when "31740-3.html"
      st.start_quest
      st.take_items(CARADINE_LETTER_LAST, -1)
    when "31740-5.html"
      if st.cond?(1)
        st.set_cond(2, true)
        pc.tele_to_location(CARADINE_LOC, 0)
      end
    when "31745-5.html"
      if st.cond?(2)
        pc.noble = true
        st.add_exp_and_sp(93836, 0)
        st.give_items(NOBLESS_TIARA, 1)
        npc.target = pc
        npc.do_cast(MIMIRS_ELIXIR)
        pc.send_packet(SocialAction.new(pc.l2id, 3))
        st.exit_quest(false, true)
      end
    else
      # [automatically added else]
    end


    event
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.started? && !pc.subclass_active?
      return "no_sub.html"
    end

    case npc.id
    when CARADINE
      case st.state
      when State::CREATED
        if pc.quest_completed?(Q00246_PossessorOfAPreciousSoul3.simple_name)
          html = pc.level >= 75 ? "31740-1.htm" : "31740-2.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "31740-6.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when LADY_OF_LAKE
      if st.cond?(2)
        html = "31745-1.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
