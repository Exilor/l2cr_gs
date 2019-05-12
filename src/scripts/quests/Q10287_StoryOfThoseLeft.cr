class Scripts::Q10287_StoryOfThoseLeft < Quest
  # NPCs
  private RAFFORTY = 32020
  private JINIA = 32760
  private KEGOR = 32761
  # Misc
  private MIN_LEVEL = 82
  # Location
  private EXIT_LOC = Location.new(113793, -109342, -845, 0)

  def initialize
    super(10287, self.class.simple_name, "Story of Those Left")

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY, JINIA, KEGOR)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "32020-02.htm"
      st.start_quest
      st.memo_state = 1
      st.set_memo_state_ex(1, 0)
      st.set_memo_state_ex(2, 0)
      html = event
    when "32020-08.html"
      if st.memo_state?(2)
        html = event
      end
    when "32760-02.html"
      if st.memo_state?(1)
        html = event
      end
    when "32760-03.html"
      if st.memo_state?(1)
        st.set_memo_state_ex(1, 1)
        st.set_cond(3, true)
        html = event
      end
    when "32760-06.html"
      if st.memo_state?(2)
        st.set_cond(5, true)
        pc.tele_to_location(EXIT_LOC, 0)
        html = event # TODO: missing "jinia_npc_q10287_06.htm"
      end
    when "32761-02.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 1) && st.memo_state_ex?(2, 0)
        html = event
      end
    when "32761-03.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 1) && st.memo_state_ex?(2, 0)
        st.set_memo_state_ex(2, 1)
        st.set_cond(4, true)
        html = event
      end
    when "10549", "10550", "10551", "10552", "10553", "14219"
      if st.memo_state?(2)
        st.reward_items(event.to_i, 1)
        html = "32020-09.html"
        st.exit_quest(false, true)
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == RAFFORTY
        html = "32020-04.html"
      end
    elsif st.created?
      if npc.id == RAFFORTY
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10286_ReunionWithSirra.simple_name)
          html = "32020-01.htm"
        else
          html = "32020-03.htm"
        end
      end
    elsif st.started?
      case npc.id
      when RAFFORTY
        if st.memo_state?(1)
          html = pc.level >= MIN_LEVEL ? "32020-05.html" : "32020-06.html"
        elsif st.memo_state?(2)
          html = "32020-07.html"
        end
      when JINIA
        if st.memo_state?(1)
          msx1 = st.get_memo_state_ex(1)
          msx2 = st.get_memo_state_ex(2)
          if msx1 == 0 && msx2 == 0
            html = "32760-01.html"
          elsif msx1 == 1 && msx2 == 0
            html = "32760-04.html"
          elsif msx1 == 1 && msx2 == 1
            st.set_cond(5, true)
            st.memo_state = 2
            st.set_memo_state_ex(1, 0)
            st.set_memo_state_ex(2, 0)
            world = InstanceManager.get_player_world(pc).not_nil!
            world.remove_allowed(pc.l2id)
            pc.instance_id = 0
            html = "32760-05.html"
          end
        end
      when KEGOR
        if st.memo_state?(1)
          msx1 = st.get_memo_state_ex(1)
          msx2 = st.get_memo_state_ex(2)
          if msx1 == 1 && msx2 == 0
            html = "32761-01.html"
          elsif msx1 == 0 && msx2 == 0
            html = "32761-04.html"
          elsif msx1 == 1 && msx2 == 1
            html = "32761-05.html"
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
