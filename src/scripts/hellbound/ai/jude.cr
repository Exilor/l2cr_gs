class NpcAI::Jude < AbstractNpcAI
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

  def on_adv_event(event, npc, player)
    return unless player

    if event.casecmp?("TreasureSacks")
      if HellboundEngine.level == 3
        if get_quest_items_count(player, NATIVE_TREASURE) >= 40
          take_items(player, NATIVE_TREASURE, 40)
          give_items(player, RING_OF_WIND_MASTERY, 1)
          return "32356-02.htm"
        end
      end
      return "32356-02a.htm"
    end

    super
  end

  def on_first_talk(npc, player)
    case HellboundEngine.level
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
