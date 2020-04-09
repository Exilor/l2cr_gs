class Scripts::Q00313_CollectSpores < Quest
  # NPC
  private HERBIEL = 30150
  # Item
  private SPORE_SAC = 1118
  # Misc
  private MIN_LEVEL = 8
  private REQUIRED_SAC_COUNT = 10
  # Monster
  private SPORE_FUNGUS = 20509

  def initialize
    super(313, self.class.simple_name, "Collect Spores")

    add_start_npc(HERBIEL)
    add_talk_id(HERBIEL)
    add_kill_id(SPORE_FUNGUS)
    register_quest_items(SPORE_SAC)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30150-05.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "30150-04.htm"
      html = event
    else
      # [automatically added else]
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, killer, false)
      if st.give_item_randomly(npc, SPORE_SAC, 1, REQUIRED_SAC_COUNT, 0.4, true)
        st.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30150-03.htm" : "30150-02.htm"
    when State::STARTED
      case st.cond
      when 1
        if st.get_quest_items_count(SPORE_SAC) < REQUIRED_SAC_COUNT
          html = "30150-06.html"
        end
      when 2
        if st.get_quest_items_count(SPORE_SAC) >= REQUIRED_SAC_COUNT
          st.give_adena(3500, true)
          st.exit_quest(true, true)
          html = "30150-07.html"
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
