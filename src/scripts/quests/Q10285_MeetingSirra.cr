class Scripts::Q10285_MeetingSirra < Quest
  # NPCs
  private RAFFORTY = 32020
  private FREYAS_STEWARD = 32029
  private JINIA = 32760
  private KEGOR = 32761
  private SIRRA = 32762
  private JINIA2 = 32781
  # Misc
  private MIN_LEVEL = 82
  # Locations
  private EXIT_LOC = Location.new(113793, -109342, -845, 0)
  private FREYA_LOC = Location.new(103045, -124361, -2768, 0)

  def initialize
    super(10285, self.class.simple_name, "Meeting Sirra")

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY, JINIA, KEGOR, SIRRA, JINIA2, FREYAS_STEWARD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32020-02.htm"
      html = event
    when "32020-03.htm"
      st.start_quest
      st.memo_state = 1
      st.set_memo_state_ex(1, 0)
      html = event
    when "32760-02.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 0)
        st.set_memo_state_ex(1, 1)
        st.set_cond(3, true)
        html = event
      end
    when "32760-05.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 2)
        html = event
      end
    when "32760-06.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 2)
        npc = npc.not_nil!
        sirra = add_spawn(SIRRA, -23905, -8790, -5384, 56238, false, 0, false, npc.instance_id)
        say = NpcSay.new(sirra.l2id, Say2::NPC_ALL, sirra.id, NpcString::THERES_NOTHING_YOU_CANT_SAY_I_CANT_LISTEN_TO_YOU_ANYMORE)
        sirra.broadcast_packet(say)
        st.set_memo_state_ex(1, 3)
        st.set_cond(5, true)
        html = event
      end
    when "32760-09.html", "32760-10.html", "32760-11.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 4)
        html = event
      end
    when "32760-12.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 4)
        st.set_memo_state_ex(1, 5)
        st.set_cond(7, true)
        html = event
      end
    when "32760-13.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 5)
        st.set_memo_state_ex(1, 0)
        st.memo_state = 2
        world = InstanceManager.get_player_world(pc).not_nil!
        world.remove_allowed(pc.l2id)
        pc.instance_id = 0
        html = event
      end
    when "32760-14.html"
      if st.memo_state?(2)
        pc.tele_to_location(EXIT_LOC, 0)
        html = event
      end
    when "32761-02.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 1)
        st.set_memo_state_ex(1, 2)
        st.set_cond(4, true)
        html = event
      end
    when "32762-02.html", "32762-03.html", "32762-04.html", "32762-05.html",
         "32762-06.html", "32762-07.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 3)
        html = event
      end
    when "32762-08.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 3)
        npc = npc.not_nil!
        st.set_memo_state_ex(1, 4)
        st.set_cond(6, true)
        html = event
        npc.delete_me
      end
    when "32781-02.html", "32781-03.html"
      if st.memo_state?(2)
        html = event
      end
    when "TELEPORT"
      if pc.level >= MIN_LEVEL
        pc.tele_to_location(FREYA_LOC, 0)
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == RAFFORTY
        html = "32020-05.htm"
      end
    elsif st.created?
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10284_AcquisitionOfDivineSword.simple_name)
        html = "32020-01.htm"
      else
        html = "32020-04.htm"
      end
    elsif st.started?
      case npc.id
      when RAFFORTY
        case st.memo_state
        when 1
          html = pc.level >= MIN_LEVEL ? "32020-06.html" : "32020-09.html"
        when 2
          html = "32020-07.html"
        when 3
          st.give_adena(283425, true)
          st.add_exp_and_sp(939075, 83855)
          st.exit_quest(false, true)
          html = "32020-08.html"
        end
      when JINIA
        if st.memo_state?(1)
          case st.get_memo_state_ex(1)
          when 0
            html = "32760-01.html"
          when 1
            html = "32760-03.html"
          when 2
            html = "32760-04.html"
          when 3
            html = "32760-07.html"
          when 4
            html = "32760-08.html"
          when 5
            html = "32760-15.html"
          end
        end
      when KEGOR
        if st.memo_state?(1)
          case st.get_memo_state_ex(1)
          when 1
            html = "32761-01.html"
          when 2
            html = "32761-03.html"
          when 3
            html = "32761-04.html"
          end
        end
      when SIRRA
        if st.memo_state?(1)
          if st.memo_state_ex?(1, 3)
            html = "32762-01.html"
          elsif st.memo_state_ex?(1, 4)
            html = "32762-09.html"
          end
        end
      when JINIA2
        if st.memo_state?(2)
          html = "32781-01.html"
        elsif st.memo_state?(3)
          html = "32781-04.html"
        end
      when FREYAS_STEWARD
        if st.memo_state?(2)
          html = "32029-01.html"
          st.set_cond(8, true)
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
