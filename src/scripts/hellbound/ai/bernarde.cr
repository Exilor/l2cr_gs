class Scripts::Bernarde < AbstractNpcAI
  # NPCs
  private BERNARDE = 32300
  # Misc
  private NATIVE_TRANSFORM = 101
  # Items
  private HOLY_WATER = 9673
  private DARION_BADGE = 9674
  private TREASURE = 9684

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_first_talk_id(BERNARDE)
    add_start_npc(BERNARDE)
    add_talk_id(BERNARDE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when "HolyWater"
      if HellboundEngine.level == 2
        if pc.inventory.get_inventory_item_count(DARION_BADGE, -1, false) >= 5
          if pc.exchange_items_by_id("Quest", npc, DARION_BADGE, 5, HOLY_WATER, 1, true)
            return "32300-02b.htm"
          end
        end
      end
      event = "32300-02c.htm"
    when "Treasure"
      if HellboundEngine.level == 3 && has_quest_items?(pc, TREASURE)
        trust = (get_quest_items_count(pc, TREASURE) * 1000).to_i
        HellboundEngine.update_trust(trust, true)
        take_items(pc, TREASURE, -1)
        return "32300-02d.htm"
      end
      event = "32300-02e.htm"
    when "rumors"
      event = "32300-#{HellboundEngine.level}r.htm"
    else
      # [automatically added else]
    end


    event
  end

  def on_first_talk(npc, pc)
    case HellboundEngine.level
    when 0, 1
      transformed?(pc) ? "32300-01a.htm" : "32300-01.htm"
    when 2
      transformed?(pc) ? "32300-02.htm" : "32300-03.htm"
    when 3
      transformed?(pc) ? "32300-01c.htm" : "32300-03.htm"
    when 4
      transformed?(pc) ? "32300-01d.htm" : "32300-03.htm"
    else
      transformed?(pc) ? "32300-01f.htm" : "32300-03.htm"
    end
  end

  private def transformed?(pc)
    return false unless pc.transformed?
    return false unless transform = pc.transformation
    transform.id == NATIVE_TRANSFORM
  end
end
