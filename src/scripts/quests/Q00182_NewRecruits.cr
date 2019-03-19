class Quests::Q00182_NewRecruits < Quest
  # NPCs
  private KEKROPUS = 32138
  private MENACING_MACHINE = 32258
  # Misc
  private MIN_LEVEL = 17
  private MAX_LEVEL = 21
  # Rewards
  private RED_CRESCENT_EARRING = 10122
  private RING_OF_DEVOTION = 10124

  def initialize
    super(182, self.class.simple_name, "New Recruits")

    add_start_npc(KEKROPUS)
    add_talk_id(KEKROPUS, MENACING_MACHINE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32138-03.htm"
      if pc.level >= MIN_LEVEL && pc.level <= MAX_LEVEL
        if pc.in_category?(CategoryType::FIRST_CLASS_GROUP)
          htmltext = event
        end
      end
    when "32138-04.htm"
      if pc.level >= MIN_LEVEL && pc.level <= MAX_LEVEL
        if pc.in_category?(CategoryType::FIRST_CLASS_GROUP)
          st.start_quest
          st.memo_state = 1
          htmltext = event
        end
      end
    when "32258-02.html", "32258-03.html"
      if st.memo_state?(1)
        htmltext = event
      end
    when "32258-04.html"
      if st.memo_state?(1)
        give_items(pc, RED_CRESCENT_EARRING, 2)
        st.exit_quest(false, true)
        htmltext = event
      end
    when "32258-05.html"
      if st.memo_state?(1)
        give_items(pc, RING_OF_DEVOTION, 2)
        st.exit_quest(false, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.completed?
      if npc.id == KEKROPUS
        htmltext = get_already_completed_msg(pc)
      end
    elsif st.created?
      if pc.race.kamael?
        htmltext = "32138-01.htm"
      elsif pc.level >= MIN_LEVEL && pc.level <= MAX_LEVEL && pc.in_category?(CategoryType::FIRST_CLASS_GROUP)
        htmltext = "32138-02.htm"
      elsif pc.level < MIN_LEVEL || pc.level > MAX_LEVEL || !pc.in_category?(CategoryType::FIRST_CLASS_GROUP)
        htmltext = "32138-05.htm"
      end
    elsif st.started?
      case npc.id
      when KEKROPUS
        if st.memo_state?(1)
          htmltext = "32138-06.html"
        end
      when MENACING_MACHINE
        if st.memo_state?(1)
          htmltext = "32258-01.html"
        end
      end
    end

    htmltext || get_no_quest_msg(pc)
  end
end
