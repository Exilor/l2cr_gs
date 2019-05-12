class Scripts::Tunatun < AbstractNpcAI
  # NPC
  private TUNATUN = 31537
  # Item
  private BEAST_HANDLERS_WHIP = 15473
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(TUNATUN)
    add_first_talk_id(TUNATUN)
    add_talk_id(TUNATUN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if event == "Whip"
      if has_quest_items?(pc, BEAST_HANDLERS_WHIP)
        return "31537-01.html"
      end

      st = pc.get_quest_state("Q00020_BringUpWithLove")
      if st.nil? && pc.level < MIN_LEVEL
        return "31537-02.html"
      elsif st || pc.level >= MIN_LEVEL
        give_items(pc, BEAST_HANDLERS_WHIP, 1)
        return "31537-03.html"
      end
    end

    event
  end
end
