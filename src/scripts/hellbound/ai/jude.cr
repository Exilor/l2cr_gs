class Scripts::Jude < AbstractNpcAI
  # NPCs
  private JUDE = 32356
  private NATIVE_TREASURE = 9684
  private RING_OF_WIND_MASTERY = 9677

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_first_talk_id(JUDE)
    add_start_npc(JUDE)
    add_talk_id(JUDE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if event.casecmp?("TreasureSacks")
      if HellboundEngine.instance.level == 3
        if get_quest_items_count(pc, NATIVE_TREASURE) >= 40
          take_items(pc, NATIVE_TREASURE, 40)
          give_items(pc, RING_OF_WIND_MASTERY, 1)
          return "32356-02.htm"
        end
      end
      return "32356-02a.htm"
    end

    super
  end

  def on_first_talk(npc, pc)
    case HellboundEngine.instance.level
    when 0..2
      "32356-01.htm"
    when 3, 4
      "32356-01c.htm"
    when 5
      "32356-01a.htm"
    else
      "32356-01b.htm"
    end
  end
end
