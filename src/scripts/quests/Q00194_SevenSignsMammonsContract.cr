class Scripts::Q00194_SevenSignsMammonsContract < Quest
  # NPCs
  private SIR_GUSTAV_ATHEBALDT = 30760
  private CLAUDIA_ATHEBALDT = 31001
  private COLIN = 32571
  private FROG = 32572
  private TESS = 32573
  private KUTA = 32574
  # Items
  private ATHEBALDTS_INTRODUCTION = 13818
  private NATIVES_GLOVE = 13819
  private FROG_KINGS_BEAD = 13820
  private GRANDA_TESS_CANDY_POUCH = 13821
  # Misc
  private MIN_LEVEL = 79
  # Skills
  private TRANSFORMATION_FROG = SkillHolder.new(6201)
  private TRANSFORMATION_KID = SkillHolder.new(6202)
  private TRANSFORMATION_NATIVE = SkillHolder.new(6203)

  def initialize
    super(194, self.class.simple_name, "Seven Signs, Mammon's Contract")

    add_start_npc(SIR_GUSTAV_ATHEBALDT)
    add_talk_id(
      SIR_GUSTAV_ATHEBALDT, COLIN, FROG, TESS, KUTA, CLAUDIA_ATHEBALDT
    )
    register_quest_items(
      ATHEBALDTS_INTRODUCTION, NATIVES_GLOVE, FROG_KINGS_BEAD,
      GRANDA_TESS_CANDY_POUCH
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    npc = npc.not_nil!

    html = nil
    case event
    when "30760-02.html"
      st.start_quest
      html = event
    when "30760-03.html"
      if st.cond?(1)
        html = event
      end
    when "30760-04.html"
      if st.cond?(1)
        html = event
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
      end
    when "showmovie"
      if st.cond?(1)
        st.set_cond(2, true)
        pc.show_quest_movie(10)
        return ""
      end
    when "30760-07.html"
      if st.cond?(2)
        st.give_items(ATHEBALDTS_INTRODUCTION, 1)
        st.set_cond(3, true)
        html = event
      end
    when "32571-03.html", "32571-04.html"
      if st.cond?(3) && st.has_quest_items?(ATHEBALDTS_INTRODUCTION)
        html = event
      end
    when "32571-05.html"
      if st.cond?(3) && st.has_quest_items?(ATHEBALDTS_INTRODUCTION)
        st.take_items(ATHEBALDTS_INTRODUCTION, -1)
        npc.target = pc
        npc.do_cast(TRANSFORMATION_FROG)
        st.set_cond(4, true)
        html = event
      end
    when "32571-07.html"
      if st.cond?(4) && pc.transformation_id != 111 && !st.has_quest_items?(FROG_KINGS_BEAD)
        npc.target = pc
        npc.do_cast(TRANSFORMATION_FROG)
        html = event
      end
    when "32571-09.html"
      if st.cond?(4) && pc.transformation_id == 111 && !st.has_quest_items?(FROG_KINGS_BEAD)
        pc.stop_all_effects
        html = event
      end
    when "32571-11.html"
      if st.cond?(5) && st.has_quest_items?(FROG_KINGS_BEAD)
        st.take_items(FROG_KINGS_BEAD, -1)
        st.set_cond(6, true)
        html = event
        if pc.transformation_id == 111
          pc.stop_all_effects
        end
      end
    when "32571-13.html"
      if st.cond?(6)
        npc.target = pc
        npc.do_cast(TRANSFORMATION_KID)
        st.set_cond(7, true)
        html = event
      end
    when "32571-15.html"
      if st.cond?(7) && pc.transformation_id != 112 && !st.has_quest_items?(GRANDA_TESS_CANDY_POUCH)
        npc.target = pc
        npc.do_cast(TRANSFORMATION_KID)
        html = event
      end
    when "32571-17.html"
      if st.cond?(7) && pc.transformation_id == 112 && !st.has_quest_items?(GRANDA_TESS_CANDY_POUCH)
        pc.stop_all_effects
        html = event
      end
    when "32571-19.html"
      if st.cond?(8) && st.has_quest_items?(GRANDA_TESS_CANDY_POUCH)
        st.take_items(GRANDA_TESS_CANDY_POUCH, -1)
        st.set_cond(9, true)
        html = event
        if pc.transformation_id == 112
          pc.stop_all_effects
        end
      end
    when "32571-21.html"
      if st.cond?(9)
        npc.target = pc
        npc.do_cast(TRANSFORMATION_NATIVE)
        st.set_cond(10, true)
        html = event
      end
    when "32571-23.html"
      if st.cond?(10) && pc.transformation_id != 124
        unless st.has_quest_items?(NATIVES_GLOVE)
          npc.target = pc
          npc.do_cast(TRANSFORMATION_NATIVE)
          html = event
        end
      end
    when "32571-25.html"
      if st.cond?(10) && pc.transformation_id == 124
        unless st.has_quest_items?(NATIVES_GLOVE)
          pc.stop_all_effects
          html = event
        end
      end
    when "32571-27.html"
      if st.cond?(11) && st.has_quest_items?(NATIVES_GLOVE)
        st.take_items(NATIVES_GLOVE, -1)
        st.set_cond(12, true)
        html = event
        if pc.transformation_id == 124
          pc.stop_all_effects
        end
      end
    when "32572-03.html", "32572-04.html"
      if st.cond?(4)
        html = event
      end
    when "32572-05.html"
      if st.cond?(4)
        st.give_items(FROG_KINGS_BEAD, 1)
        st.set_cond(5, true)
        html = event
      end
    when "32573-03.html"
      if st.cond?(7)
        html = event
      end
    when "32573-04.html"
      if st.cond?(7)
        st.give_items(GRANDA_TESS_CANDY_POUCH, 1)
        st.set_cond(8, true)
        html = event
      end
    when "32574-03.html", "32574-04.html"
      if st.cond?(10)
        html = event
      end
    when "32574-05.html"
      if st.cond?(10)
        st.give_items(NATIVES_GLOVE, 1)
        st.set_cond(11, true)
        html = event
      end
    when "31001-02.html"
      if st.cond?(12)
        html = event
      end
    when "31001-03.html"
      if st.cond?(12)
        if pc.level >= MIN_LEVEL
          st.add_exp_and_sp(52518015, 5817677)
          st.exit_quest(false, true)
          html = event
        else
          html = "level_check.html"
        end
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == SIR_GUSTAV_ATHEBALDT
        if pc.level >= MIN_LEVEL && pc.quest_completed?(Q00193_SevenSignsDyingMessage.simple_name)
          html = "30760-01.htm"
        else
          html = "30760-05.html"
        end
      end
    when State::STARTED
      case npc.id
      when SIR_GUSTAV_ATHEBALDT
        if st.cond?(1)
          html = "30760-02.html"
        elsif st.cond?(2)
          html = "30760-06.html"
        elsif st.cond?(3) && st.has_quest_items?(ATHEBALDTS_INTRODUCTION)
          html = "30760-08.html"
        end
      when COLIN
        case st.cond
        when 1, 2
          html = "32571-01.html"
        when 3
          if st.has_quest_items?(ATHEBALDTS_INTRODUCTION)
            html = "32571-02.html"
          end
        when 4
          unless st.has_quest_items?(FROG_KINGS_BEAD)
            if pc.transformation_id != 111
              html = "32571-06.html"
            else
              html = "32571-08.html"
            end
          end
        when 5
          if st.has_quest_items?(FROG_KINGS_BEAD)
            html = "32571-10.html"
          end
        when 6
          html = "32571-12.html"
        when 7
          unless st.has_quest_items?(GRANDA_TESS_CANDY_POUCH)
            if pc.transformation_id != 112
              html = "32571-14.html"
            else
              html = "32571-16.html"
            end
          end
        when 8
          if st.has_quest_items?(GRANDA_TESS_CANDY_POUCH)
            html = "32571-18.html"
          end
        when 9
          html = "32571-20.html"
        when 10
          unless st.has_quest_items?(NATIVES_GLOVE)
            if pc.transformation_id != 124
              html = "32571-22.html"
            else
              html = "32571-24.html"
            end
          end
        when 11
          if st.has_quest_items?(NATIVES_GLOVE)
            html = "32571-26.html"
          end
        when 12
          html = "32571-28.html"
        else
          # [automatically added else]
        end

      when FROG
        case st.cond
        when 1..3
          html = "32572-01.html"
        when 4
          if pc.transformation_id == 111
            html = "32572-02.html"
          else
            html = "32572-06.html"
          end
        when 5
          if st.has_quest_items?(FROG_KINGS_BEAD) && pc.transformation_id == 111
            html = "32572-07.html"
          end
        else
          # [automatically added else]
        end

      when TESS
        case st.cond
        when 1..6
          html = "32573-01.html"
        when 7
          if pc.transformation_id == 112
            html = "32573-02.html"
          else
            html = "32573-05.html"
          end
        when 8
          if st.has_quest_items?(GRANDA_TESS_CANDY_POUCH)
            if pc.transformation_id == 112
              html = "32573-06.html"
            end
          end
        else
          # [automatically added else]
        end

      when KUTA
        case st.cond
        when 1..9
          html = "32574-01.html"
        when 10
          if pc.transformation_id == 124
            html = "32574-02.html"
          else
            html = "32574-06.html"
          end
        when 11
          if st.has_quest_items?(NATIVES_GLOVE) && pc.transformation_id == 124
            html = "32574-07.html"
          end
        else
          # [automatically added else]
        end

      when CLAUDIA_ATHEBALDT
        if st.cond?(12)
          html = "31001-01.html"
        end
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
