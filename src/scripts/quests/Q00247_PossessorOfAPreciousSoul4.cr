class Quests::Q00247_PossessorOfAPreciousSoul4 < Quest
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

  def on_adv_event(event, npc, player)
    return unless player

    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end
    unless player.subclass_active?
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
        player.tele_to_location(CARADINE_LOC, 0)
      end
    when "31745-5.html"
      if st.cond?(2)
        player.noble = true
        st.add_exp_and_sp(93836, 0)
        st.give_items(NOBLESS_TIARA, 1)
        npc.target = player
        npc.do_cast(MIMIRS_ELIXIR)
        player.send_packet(SocialAction.new(player.l2id, 3))
        st.exit_quest(false, true)
      end
    end

    event
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    if st.started? && !player.subclass_active?
      return "no_sub.html"
    end

    case npc.id
    when CARADINE
      case st.state
      when State::CREATED
        if player.quest_completed?(Q00246_PossessorOfAPreciousSoul3.simple_name)
          htmltext = player.level >= 75 ? "31740-1.htm" : "31740-2.html"
        end
      when State::STARTED
        if st.cond?(1)
          htmltext = "31740-6.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when LADY_OF_LAKE
      if st.cond?(2)
        htmltext = "31745-1.html"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
