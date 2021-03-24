class Scripts::Q00998_FallenAngelSelect < Quest
  # NPCs
  private NATOOLS = 30894
  # Misc
  private MIN_LEVEL = 38

  def initialize
    super(998, self.class.simple_name, "Fallen Angel - Select")

    self.custom = true
    add_start_npc(NATOOLS)
    add_talk_id(NATOOLS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && get_quest_state(pc, false)

    case event
    when "30894-01.html", "30894-02.html", "30894-03.html"
      return event
    when "dawn"
      start_quest(Q00142_FallenAngelRequestOfDawn.simple_name, pc)
    when "dusk"
      start_quest(Q00143_FallenAngelRequestOfDusk.simple_name, pc)
    end

    nil
  end

  private def start_quest(name, pc)
    if q = QuestManager.get_quest(name)
      q.new_quest_state(pc)
      q.notify_event("30894-01.html", nil, pc)
      pc.get_quest_state!(name).state = State::COMPLETED
    end
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.nil? || !st.started?
      return get_no_quest_msg(pc)
    end

    qs = pc.get_quest_state(Q00141_ShadowFoxPart3.simple_name)
    if pc.level >= MIN_LEVEL && qs && qs.completed?
      "30894-01.html"
    else
      "30894-00.html"
    end
  end
end
