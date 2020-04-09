class Scripts::Q00125_TheNameOfEvil1 < Quest
  # NPCs
  private MUSHIKA = 32114
  private KARAKAWEI = 32117
  private ULU_KAIMU = 32119
  private BALU_KAIMU = 32120
  private CHUTA_KAIMU = 32121
  # Items
  private ORNITHOMIMUS_CLAW = 8779
  private DEINONYCHUS_BONE = 8780
  private EPITAPH_OF_WISDOM = 8781
  private GAZKH_FRAGMENT = 8782

  private ORNITHOMIMUS = {
    22200 => 661,
    22201 => 330,
    22202 => 661,
    22219 => 327,
    22224 => 327
  }
  private DEINONYCHUS = {
    22203 => 651,
    22204 => 326,
    22205 => 651,
    22220 => 319,
    22225 => 319
  }

  def initialize
    super(125, self.class.simple_name, "The Name of Evil - 1")

    add_start_npc(MUSHIKA)
    add_talk_id(MUSHIKA, KARAKAWEI, ULU_KAIMU, BALU_KAIMU, CHUTA_KAIMU)
    add_kill_id(ORNITHOMIMUS.keys)
    add_kill_id(DEINONYCHUS.keys)
    register_quest_items(
      ORNITHOMIMUS_CLAW, DEINONYCHUS_BONE, EPITAPH_OF_WISDOM, GAZKH_FRAGMENT
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event

    case event
    when "32114-05.html"
      st.start_quest
    when "32114-08.html"
      if st.cond?(1)
        st.give_items(GAZKH_FRAGMENT, 1)
        st.set_cond(2, true)
      end
    when "32117-09.html"
      if st.cond?(2)
        st.set_cond(3, true)
      end
    when "32117-15.html"
      if st.cond?(4)
        st.set_cond(5, true)
      end
    when "T_One"
      st.set("T", "1")
      html = "32119-04.html"
    when "E_One"
      st.set("E", "1")
      html = "32119-05.html"
    when "P_One"
      st.set("P", "1")
      html = "32119-06.html"
    when "U_One"
      st.set("U", "1")
      if st.cond?(5) && st.get_int("T") > 0 && st.get_int("E") > 0 && st.get_int("P") > 0 && st.get_int("U") > 0
        html = "32119-08.html"
        st.set("Memo", "1")
      else
        html = "32119-07.html"
      end
      st.unset("T")
      st.unset("E")
      st.unset("P")
      st.unset("U")
    when "32119-07.html"
      st.unset("T")
      st.unset("E")
      st.unset("P")
      st.unset("U")
    when "32119-18.html"
      if st.cond?(5)
        st.set_cond(6, true)
        st.unset("Memo")
      end
    when "T_Two"
      st.set("T", "1")
      html = "32120-04.html"
    when "O_Two"
      st.set("O", "1")
      html = "32120-05.html"
    when "O2_Two"
      st.set("O2", "1")
      html = "32120-06.html"
    when "N_Two"
      st.set("N", "1")
      if st.cond?(6) && st.get_int("T") > 0 && st.get_int("O") > 0 && st.get_int("O2") > 0 && st.get_int("N") > 0
        html = "32120-08.html"
        st.set("Memo", "1")
      else
        html = "32120-07.html"
      end
      st.unset("T")
      st.unset("O")
      st.unset("O2")
      st.unset("N")
    when "32120-07.html"
      st.unset("T")
      st.unset("O")
      st.unset("O2")
      st.unset("N")
    when "32120-17.html"
      if st.cond?(6)
        st.set_cond(7, true)
        st.unset("Memo")
      end
    when "W_Three"
      st.set("W", "1")
      html = "32121-04.html"
    when "A_Three"
      st.set("A", "1")
      html = "32121-05.html"
    when "G_Three"
      st.set("G", "1")
      html = "32121-06.html"
    when "U_Three"
      st.set("U", "1")
      if st.cond?(7) && st.get_int("W") > 0 && st.get_int("A") > 0 && st.get_int("G") > 0 && st.get_int("U") > 0
        html = "32121-08.html"
        st.set("Memo", "1")
      else
        html = "32121-07.html"
      end
      st.unset("W")
      st.unset("A")
      st.unset("G")
      st.unset("U")
    when "32121-07.html"
      st.unset("W")
      st.unset("A")
      st.unset("G")
      st.unset("U")
    when "32121-11.html"
      st.set("Memo", "2")
    when "32121-16.html"
      st.set("Memo", "3")
    when "32121-18.html"
      if st.cond?(7) && st.has_quest_items?(GAZKH_FRAGMENT)
        st.give_items(EPITAPH_OF_WISDOM, 1)
        st.take_items(GAZKH_FRAGMENT, -1)
        st.set_cond(8, true)
        st.unset("Memo")
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 3)
      return
    end

    st = get_quest_state(member, false).not_nil!
    npc_id = npc.id
    if tmp = ORNITHOMIMUS[npc_id]?
      if st.get_quest_items_count(ORNITHOMIMUS_CLAW) < 2
        chance = tmp * Config.rate_quest_drop
        if Rnd.rand(1000) < chance
          st.give_items(ORNITHOMIMUS_CLAW, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    elsif tmp = DEINONYCHUS[npc_id]?
      if st.get_quest_items_count(DEINONYCHUS_BONE) < 2
        chance = tmp * Config.rate_quest_drop
        if Rnd.rand(1000) < chance
          st.give_items(DEINONYCHUS_BONE, 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    if st.get_quest_items_count(ORNITHOMIMUS_CLAW) == 2 && st.get_quest_items_count(DEINONYCHUS_BONE) == 2
      st.set_cond(4, true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when MUSHIKA
      case st.state
      when State::CREATED
        if pc.level < 76
          html = "32114-01a.htm"
        else
          if pc.quest_completed?(Q00124_MeetingTheElroki.simple_name)
            html = "32114-01.htm"
          else
            html = "32114-01b.htm"
          end
        end
      when State::STARTED
        case st.cond
        when 1
          html = "32114-09.html"
        when 2
          html = "32114-10.html"
        when 3..7
          html = "32114-11.html"
        when 8
          if st.has_quest_items?(EPITAPH_OF_WISDOM)
            html = "32114-12.html"
            st.add_exp_and_sp(859195, 86603)
            st.exit_quest(false, true)
          end
        else
          # [automatically added else]
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when KARAKAWEI
      if st.started?
        case st.cond
        when 1
          html = "32117-01.html"
        when 2
          html = "32117-02.html"
        when 3
          html = "32117-10.html"
        when 4
          if st.get_quest_items_count(ORNITHOMIMUS_CLAW) >= 2 && st.get_quest_items_count(DEINONYCHUS_BONE) >= 2
            st.take_items(ORNITHOMIMUS_CLAW, -1)
            st.take_items(DEINONYCHUS_BONE, -1)
            html = "32117-11.html"
          end
        when 5
          html = "32117-16.html"
        when 6, 7
          html = "32117-17.html"
        when 8
          html = "32117-18.html"
        else
          # [automatically added else]
        end

      end
    when ULU_KAIMU
      if st.started?
        case st.cond
        when 1..4
          html = "32119-01.html"
        when 5
          if st.get("Memo").nil?
            html = "32119-02.html"
            npc.broadcast_packet(MagicSkillUse.new(npc, pc, 5089, 1, 1000, 0))
            st.unset("T")
            st.unset("E")
            st.unset("P")
            st.unset("U")
          else
            html = "32119-09.html"
          end
        when 6
          html = "32119-18.html"
        else
          html = "32119-19.html"
        end
      end
    when BALU_KAIMU
      if st.started?
        case st.cond
        when 1..5
          html = "32120-01.html"
        when 6
          if st.get("Memo").nil?
            html = "32120-02.html"
            npc.broadcast_packet(MagicSkillUse.new(npc, pc, 5089, 1, 1000, 0))
            st.unset("T")
            st.unset("O")
            st.unset("O2")
            st.unset("N")
          else
            html = "32120-09.html"
          end
        when 7
          html = "32120-17.html"
        else
          html = "32119-18.html"
        end
      end
    when CHUTA_KAIMU
      if st.started?
        case st.cond
        when 1..6
          html = "32121-01.html"
        when 7
          case st.get_int("Memo")
          when 0
            html = "32121-02.html"
            npc.broadcast_packet(MagicSkillUse.new(npc, pc, 5089, 1, 1000, 0))
            st.unset("W")
            st.unset("A")
            st.unset("G")
            st.unset("U")
          when 1
            html = "32121-09.html"
          when 2
            html = "32121-19.html"
          when 3
            html = "32121-20.html"
          else
            # [automatically added else]
          end

        when 8
          html = "32121-21.html"
        else
          # [automatically added else]
        end

      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
