class Scripts::Abercrombie < AbstractNpcAI
  # NPC
  private ABERCROMBIE = 31555
  # Items
  private GOLDEN_RAM_BADGE_RECRUIT = 7246
  private GOLDEN_RAM_BADGE_SOLDIER = 7247

  def initialize
    super(self.class.simple_name, "ai/npc")
    add_first_talk_id(ABERCROMBIE)
  end

  def on_first_talk(npc, player)
    if has_quest_items?(player, GOLDEN_RAM_BADGE_SOLDIER)
      "31555-07.html"
    elsif has_quest_items?(player, GOLDEN_RAM_BADGE_RECRUIT)
      "31555-01.html"
    else
      "31555-09.html"
    end
  end
end
