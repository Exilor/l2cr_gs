class Scripts::Q10271_TheEnvelopingDarkness < Quest
  private ORBYU = 32560
  private EL = 32556
  private MEDIBAL_CORPSE = 32528
  private MEDIBAL_DOCUMENT = 13852

  def initialize
    super(10271, self.class.simple_name, "The Enveloping Darkness")

    add_start_npc(ORBYU)
    add_talk_id(ORBYU, EL, MEDIBAL_CORPSE)
    register_quest_items(MEDIBAL_DOCUMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "32560-05.html"
      st.start_quest
    when "32556-06.html"
      st.set_cond(2, true)
    when "32556-09.html"
      if st.has_quest_items?(MEDIBAL_DOCUMENT)
        st.take_items(MEDIBAL_DOCUMENT, -1)
        st.set_cond(4, true)
      end
    end


    event
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when ORBYU
      case st.state
      when State::CREATED
        if pc.level >= 75 && pc.quest_completed?(Q10269_ToTheSeedOfDestruction.simple_name)
          html = "32560-01.htm"
        else
          html = "32560-02.html"
        end
      when State::STARTED
        case st.cond
        when 1
          html = "32560-05.html" # TODO this html should probably be different
        when 2
          html = "32560-06.html"
        when 3
          html = "32560-07.html"
        when 4
          html = "32560-08.html"
          st.give_adena(62516, true)
          st.add_exp_and_sp(377403, 37867)
          st.exit_quest(false, true)
        end

      when State::COMPLETED
        html = "32560-03.html"
      end

    when EL
      if st.completed?
        html = "32556-02.html"
      elsif st.started?
        case st.cond
        when 1
          html = "32556-01.html"
        when 2
          html = "32556-07.html"
        when 3
          html = "32556-08.html"
        when 4
          html = "32556-09.html"
        end

      end
    when MEDIBAL_CORPSE
      if st.completed?
        html = "32528-02.html"
      elsif st.started?
        case st.cond
        when 2
          html = "32528-01.html"
          st.set_cond(3, true)
          st.give_items(MEDIBAL_DOCUMENT, 1)
        when 3, 4
          html = "32528-03.html"
        end

      end
    end


    html || get_no_quest_msg(pc)
  end
end
