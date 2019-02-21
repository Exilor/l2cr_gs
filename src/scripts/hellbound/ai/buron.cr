class NpcAI::Buron < AbstractNpcAI
  private BURON = 32345
  private HELMET = 9669
  private TUNIC = 9670
  private PANTS = 9671
  private DARION_BADGE = 9674

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_first_talk_id(BURON)
    add_start_npc(BURON)
    add_talk_id(BURON)
  end

  def on_adv_event(event, npc, player)
    return unless player

    htmltext = event
    if event.casecmp?("Rumor")
      htmltext = "32345-#{HellboundEngine.level}r.htm"
    else
      if HellboundEngine.level < 2
        htmltext = "32345-lowlvl.htm"
      else
        if get_quest_items_count(player, DARION_BADGE) >= 10
          take_items(player, DARION_BADGE, 10)
          if event.casecmp?("Tunic")
            player.add_item("Quest", TUNIC, 1, npc, true)
          elsif event.casecmp?("Helmet")
            player.add_item("Quest", HELMET, 1, npc, true)
          elsif event.casecmp?("Pants")
            player.add_item("Quest", PANTS, 1, npc, true)
          end
          htmltext = nil
        else
          htmltext = "32345-noitems.htm"
        end
      end
    end

    htmltext
  end

  def on_first_talk(npc, player)
    get_quest_state!(player)

    case HellboundEngine.level
    when 1
      "32345-01.htm"
    when 2..4
      "32345-02.htm"
    else
      "32345-01a.htm"
    end
  end
end
