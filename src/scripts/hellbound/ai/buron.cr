class Scripts::Buron < AbstractNpcAI
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

  def on_adv_event(event, npc, pc)
    return unless pc

    html = event
    if event.casecmp?("Rumor")
      html = "32345-#{HellboundEngine.level}r.htm"
    else
      if HellboundEngine.level < 2
        html = "32345-lowlvl.htm"
      else
        if get_quest_items_count(pc, DARION_BADGE) >= 10
          take_items(pc, DARION_BADGE, 10)
          case event.casecmp
          when "Tunic"
            pc.add_item("Quest", TUNIC, 1, npc, true)
          when "Helmet"
            pc.add_item("Quest", HELMET, 1, npc, true)
          when "Pants"
            pc.add_item("Quest", PANTS, 1, npc, true)
          end
          html = nil
        else
          html = "32345-noitems.htm"
        end
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    get_quest_state!(pc)

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
