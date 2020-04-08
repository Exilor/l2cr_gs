class Scripts::Jinia < AbstractNpcAI
  # NPC
  private JINIA = 32781
  # Items
  private FROZEN_CORE = 15469
  private BLACK_FROZEN_CORE = 15470
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(JINIA)
    add_first_talk_id(JINIA)
    add_talk_id(JINIA)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    html = event

    case event
    when "check"
      if has_at_least_one_quest_item?(pc, FROZEN_CORE, BLACK_FROZEN_CORE)
        html = "32781-03.html"
      else
        st = pc.get_quest_state(Q10286_ReunionWithSirra.simple_name)
        if st && st.completed?
          give_items(pc, FROZEN_CORE, 1)
        else
          give_items(pc, BLACK_FROZEN_CORE, 1)
        end

        html = "32781-04.html"
      end
    else
      # automatically added
    end


    html
  end

  def on_first_talk(npc, pc)
    st = pc.get_quest_state(Q10286_ReunionWithSirra.simple_name)
    if st && pc.level >= MIN_LEVEL
      if st.completed?
        return "32781-02.html"
      elsif st.cond?(5) || st.cond?(6)
        return "32781-09.html"
      end
    end

    "32781-01.html"
  end
end