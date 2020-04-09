class Scripts::Q10284_AcquisitionOfDivineSword < Quest
  # NPCs
  private RAFFORTY = 32020
  private KRUN = 32653
  private TARUN = 32654
  private JINIA = 32760
  # Misc
  private MIN_LEVEL = 82
  # Item
  private COLD_RESISTANCE_POTION = 15514
  # Location
  private EXIT_LOC = Location.new(113793, -109342, -845, 0)

  def initialize
    super(10284, self.class.simple_name, "Acquisition of Divine Sword")

    add_start_npc(RAFFORTY)
    add_talk_id(RAFFORTY, JINIA, TARUN, KRUN)
    register_quest_items(COLD_RESISTANCE_POTION)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32020-02.html"
      st.start_quest
      st.memo_state = 1
      st.set_memo_state_ex(1, 0) # Custom line
      st.set_memo_state_ex(2, 0) # Custom line
      st.set_memo_state_ex(3, 0) # Custom line
      html = event
    when "32020-03.html", "32760-02a.html", "32760-02b.html", "32760-03a.html",
         "32760-03b.html", "32760-04a.html", "32760-04b.html"
      if st.memo_state?(1)
        html = event
      end
    when "32760-02c.html"
      if st.memo_state?(1)
        st.set_memo_state_ex(1, 1)
        html = event
      end
    when "another_story"
      if st.memo_state?(1)
        msx1 = st.get_memo_state_ex(1)
        msx2 = st.get_memo_state_ex(2)
        msx3 = st.get_memo_state_ex(3)
        if msx1 == 1 && msx2 == 0 && msx3 == 0
          html = "32760-05a.html"
        elsif msx1 == 0 && msx2 == 1 && msx3 == 0
          html = "32760-05b.html"
        elsif msx1 == 0 && msx2 == 0 && msx3 == 1
          html = "32760-05c.html"
        elsif msx1 == 0 && msx2 == 1 && msx3 == 1
          html = "32760-05d.html"
        elsif msx1 == 1 && msx2 == 0 && msx3 == 1
          html = "32760-05e.html"
        elsif msx1 == 1 && msx2 == 1 && msx3 == 0
          html = "32760-05f.html"
        elsif msx1 == 1 && msx2 == 1 && msx3 == 1
          html = "32760-05g.html"
        end
      end
    when "32760-03c.html"
      if st.memo_state?(1)
        st.set_memo_state_ex(2, 1)
        html = event
      end
    when "32760-04c.html"
      if st.memo_state?(1)
        st.set_memo_state_ex(3, 1)
        html = event
      end
    when "32760-06.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 1)
        if st.memo_state_ex?(2, 1) && st.memo_state_ex?(3, 1)
          html = event
        end
      end
    when "32760-07.html"
      if st.memo_state?(1) && st.memo_state_ex?(1, 1)
        if st.memo_state_ex?(2, 1) && st.memo_state_ex?(3, 1)
          st.set_memo_state_ex(1, 0)
          st.set_memo_state_ex(2, 0)
          st.set_memo_state_ex(3, 0)
          st.set_cond(3, true)
          st.memo_state = 2
          world = InstanceManager.get_player_world(pc).not_nil!
          world.remove_allowed(pc.l2id)
          pc.instance_id = 0
          html = event
        end
      end
    when "exit_instance"
      if st.memo_state?(2)
        pc.tele_to_location(EXIT_LOC, 0)
      end
    when "32654-02.html", "32654-03.html", "32653-02.html", "32653-03.html"
      if st.memo_state?(2)
        html = event
      end
    else
      # [automatically added else]
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
      if pc.level >= MIN_LEVEL && pc.quest_completed?(Q10283_RequestOfIceMerchant.simple_name)
        html = "32020-01.htm"
      else
        html = "32020-04.html"
      end
    elsif st.started?
      case npc.id
      when RAFFORTY
        case st.memo_state
        when 1
          html = pc.level >= MIN_LEVEL ? "32020-06.html" : "32020-08.html"
        when 2
          html = "32020-07.html"
        else
          # [automatically added else]
        end

      when JINIA
        if st.memo_state?(1)
          msx1 = st.get_memo_state_ex(1)
          msx2 = st.get_memo_state_ex(2)
          msx3 = st.get_memo_state_ex(3)
          if msx1 == 0 && msx2 == 0 && msx3 == 0
            html = "32760-01.html"
          elsif msx1 == 1 && msx2 == 0 && msx3 == 0
            html = "32760-01a.html"
          elsif msx1 == 0 && msx2 == 1 && msx3 == 0
            html = "32760-01b.html"
          elsif msx1 == 0 && msx2 == 0 && msx3 == 1
            html = "32760-01c.html"
          elsif msx1 == 0 && msx2 == 1 && msx3 == 1
            html = "32760-01d.html"
          elsif msx1 == 1 && msx2 == 0 && msx3 == 1
            html = "32760-01e.html"
          elsif msx1 == 1 && msx2 == 1 && msx3 == 0
            html = "32760-01f.html"
          elsif msx1 == 1 && msx2 == 1 && msx3 == 1
            html = "32760-01g.html"
          end
        end
      when TARUN
        case st.memo_state
        when 2
          html = pc.level >= MIN_LEVEL ? "32654-01.html" : "32654-05.html"
        when 3
          st.give_adena(296425, true)
          st.add_exp_and_sp(921805, 82230)
          st.exit_quest(false, true)
          html = "32654-04.html"
        else
          # [automatically added else]
        end

      when KRUN
        case st.memo_state
        when 2
          html = pc.level >= MIN_LEVEL ? "32653-01.html" : "32653-05.html"
        when 3
          st.give_adena(296425, true)
          st.add_exp_and_sp(921805, 82230)
          st.exit_quest(false, true)
          html = "32653-04.html"
        else
          # [automatically added else]
        end

      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
