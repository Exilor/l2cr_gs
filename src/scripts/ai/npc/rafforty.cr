class NpcAI::Rafforty < AbstractNpcAI
  # NPC
  private RAFFORTY = 32020
  # Items
  private NECKLACE = 16025
  private BLESSED_NECKLACE = 16026
  private BOTTLE = 16027

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(RAFFORTY)
    add_first_talk_id(RAFFORTY)
    add_talk_id(RAFFORTY)
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    htmltext = event

    case event
    when "32020-01.html"
      unless has_quest_items?(pc, NECKLACE)
        htmltext = "32020-02.html"
      end
    when "32020-04.html"
      unless has_quest_items?(pc, BOTTLE)
        htmltext = "32020-05.html"
      end
    when "32020-07.html"
      unless has_quest_items?(pc, BOTTLE, NECKLACE)
        return "32020-08.html"
      end

      take_items(pc, NECKLACE, 1)
      take_items(pc, BOTTLE, 1)
      give_items(pc, BLESSED_NECKLACE, 1)
    end

    htmltext
  end
end
