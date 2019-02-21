class NpcAI::GhostChamberlainOfElmoreden < AbstractNpcAI
  # NPCs
  private GHOST_CHAMBERLAIN_OF_ELMOREDEN_1 = 31919
  private GHOST_CHAMBERLAIN_OF_ELMOREDEN_2 = 31920
  # Items
  private USED_GRAVE_PASS = 7261
  private ANTIQUE_BROOCH = 7262
  # Locations
  private FOUR_SEPULCHERS_LOC = Location.new(178127, -84435, -7215)
  private IMPERIAL_TOMB_LOC = Location.new(186699, -75915, -2826)

  def initialize
    super(self.class.simple_name, "ai/npc/Teleports")

    add_start_npc(GHOST_CHAMBERLAIN_OF_ELMOREDEN_1, GHOST_CHAMBERLAIN_OF_ELMOREDEN_2)
    add_talk_id(GHOST_CHAMBERLAIN_OF_ELMOREDEN_1, GHOST_CHAMBERLAIN_OF_ELMOREDEN_2)
    add_first_talk_id(GHOST_CHAMBERLAIN_OF_ELMOREDEN_1, GHOST_CHAMBERLAIN_OF_ELMOREDEN_2)
  end

  def on_adv_event(event, npc, player)
    return unless player && npc

    if event == "FOUR_SEPULCHERS"
      if has_quest_items?(player, USED_GRAVE_PASS)
        take_items(player, USED_GRAVE_PASS, 1)
        player.tele_to_location(FOUR_SEPULCHERS_LOC)
      elsif has_quest_items?(player, ANTIQUE_BROOCH)
        player.tele_to_location(FOUR_SEPULCHERS_LOC)
      else
        return "#{npc.id}-01.html"
      end
    elsif event == "IMPERIAL_TOMB"
      if has_quest_items?(player, USED_GRAVE_PASS)
        take_items(player, USED_GRAVE_PASS, 1)
        player.tele_to_location(IMPERIAL_TOMB_LOC)
      elsif has_quest_items?(player, ANTIQUE_BROOCH)
        player.tele_to_location(IMPERIAL_TOMB_LOC)
      else
        return "#{npc.id}-01.html"
      end
    end

    super
  end
end
