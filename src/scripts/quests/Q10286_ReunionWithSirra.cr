class Scripts::Q10286_ReunionWithSirra < Quest
  # NPCs
  private RAFFORTY = 32020
  private JINIA = 32760
  private SIRRA = 32762
  private JINIA2 = 32781
  # Item
  private BLACK_FROZEN_CORE = 15470
  # Misc
  private MIN_LEVEL = 82
  # Location
  private EXIT_LOC = Location.new(113793, -109342, -845, 0)

  def initialize
    super(10286, self.class.simple_name, "Reunion with Sirra")

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY, JINIA, SIRRA, JINIA2)
    register_quest_items(BLACK_FROZEN_CORE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    html = nil
    case event
    when "32020-02.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "32020-03.html"
      if st.memo_state?(1)
        st.set_memo_state_ex(1, 0)
        html = event
      end
    when "32760-02.html", "32760-03.html", "32760-04.html"
      if st.memo_state?(1)
        html = event
      end
    when "32760-05.html"
      if st.memo_state?(1)
        npc = npc.not_nil!
        sirra = add_spawn(SIRRA, -23905, -8790, -5384, 56238, false, 0, false, npc.instance_id)
        say = NpcSay.new(sirra.l2id, Say2::NPC_ALL, sirra.id, NpcString::YOU_ADVANCED_BRAVELY_BUT_GOT_SUCH_A_TINY_RESULT_HOHOHO)
        sirra.broadcast_packet(say)
        st.set_memo_state_ex(1, 1)
        st.set_cond(3, true)
        html = event
      end
    when "32760-07.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 2)
        st.memo_state = 2
        world = InstanceManager.get_player_world(pc).not_nil!
        world.remove_allowed(pc.l2id)
        pc.instance_id = 0
        html = event
      end
    when "32760-08.html"
      if st.memo_state?(2)
        st.set_cond(5, true)
        pc.tele_to_location(EXIT_LOC, 0)
        html = event # TODO: missing "jinia_npc_q10286_10.htm"
      end
    when "32762-02.html", "32762-03.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 1)
        html = event
      end
    when "32762-04.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 1)
        unless st.has_quest_items?(BLACK_FROZEN_CORE)
          st.give_items(BLACK_FROZEN_CORE, 5)
        end
        st.set_memo_state_ex(1, 2)
        st.set_cond(4, true)
        html = event
      end
    when "32781-02.html", "32781-03.html"
      if st.memo_state?(2)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == RAFFORTY
        html = "32020-05.html"
      end
    elsif st.created?
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10285_MeetingSirra.simple_name)
        html = "32020-01.htm"
      else
        html = "32020-04.htm"
      end
    elsif st.started?
      case npc.id
      when RAFFORTY
        if st.memo_state?(1)
          html = pc.level >= MIN_LEVEL ? "32020-06.html" : "32020-08.html"
        elsif st.memo_state?(2)
          html = "32020-07.html"
        end
      when JINIA
        if st.memo_state?(1)
          case st.get_memo_state_ex(1)
          when 0
            html = "32760-01.html"
          when 1
            html = "32760-05.html"
          when 2
            html = "32760-06.html"
          end
        end
      when SIRRA
        if st.memo_state?(1)
          if st.memo_state_ex?(1, 1)
            html = "32762-01.html"
          elsif st.memo_state_ex?(1, 2)
            html = "32762-05.html"
          end
        end
      when JINIA2
        if st.memo_state?(10)
          st.add_exp_and_sp(2_152_200, 181_070)
          st.exit_quest(false, true)
          html = "32781-01.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
