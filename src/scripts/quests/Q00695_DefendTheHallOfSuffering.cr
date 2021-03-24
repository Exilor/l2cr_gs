class Scripts::Q00695_DefendTheHallOfSuffering < Quest
  # NPC
  private TEPIOS = 32603
  # Misc
  private MIN_LEVEL = 75
  private MAX_LEVEL = 82

  def initialize
    super(695, self.class.simple_name, "Defend the Hall of Suffering")

    add_start_npc(TEPIOS)
    add_talk_id(TEPIOS)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32603-02.html"
      event
    when "32603-03.htm"
      if pc.level >= MIN_LEVEL
        st.start_quest(false)
        st.memo_state = 2
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        event
      end
    end
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      if pc.level.between?(MIN_LEVEL, MAX_LEVEL)
        # TODO (Adry_85): This quest can only be carried out during the Seed of Infinity 4th period or Seed of Infinity 5th period.
        return "32603-01.htm"
      elsif pc.level < MIN_LEVEL
        return "32603-04.htm"
      else
        return "32603-05.html"
      end
    elsif st.started? && st.memo_state?(2)
      return "32603-06.htm"
    end

    get_no_quest_msg(pc)
  end
end
