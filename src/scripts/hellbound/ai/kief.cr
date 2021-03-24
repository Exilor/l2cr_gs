class Scripts::Kief < AbstractNpcAI
  # NPCs
  private KIEF = 32354
  # Items
  private BOTTLE = 9672 # Magic Bottle
  private DARION_BADGE = 9674 # Darion's Badge
  private DIM_LIFE_FORCE = 9680 # Dim Life Force
  private LIFE_FORCE = 9681 # Life Force
  private CONTAINED_LIFE_FORCE = 9682 # Contained Life Force
  private STINGER = 10012 # Scorpion Poison Stinger

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")

    add_first_talk_id(KIEF)
    add_start_npc(KIEF)
    add_talk_id(KIEF)
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    case event
    when "Badges"
      case HellboundEngine.instance.level
      when 2, 3
        if has_quest_items?(pc, DARION_BADGE)
          HellboundEngine.instance.update_trust((get_quest_items_count(pc, DARION_BADGE) * 10).to_i32, true)
          take_items(pc, DARION_BADGE, -1)
          return "32354-10.htm"
        end
      else
        html = "32354-10a.htm"
      end
    when "Bottle"
      if HellboundEngine.instance.level >= 7
        if get_quest_items_count(pc, STINGER) >= 20
          take_items(pc, STINGER, 20)
          give_items(pc, BOTTLE, 1)
          html = "32354-11h.htm"
        else
          html = "32354-11i.htm"
        end
      end
    when "dlf"
      if HellboundEngine.instance.level == 7
        if has_quest_items?(pc, DIM_LIFE_FORCE)
          HellboundEngine.instance.update_trust((get_quest_items_count(pc, DIM_LIFE_FORCE) * 20).to_i32, true)
          take_items(pc, DIM_LIFE_FORCE, -1)
          html = "32354-11a.htm"
        else
          html = "32354-11b.htm"
        end
      end
    when "lf"
      if HellboundEngine.instance.level == 7
        if has_quest_items?(pc, LIFE_FORCE)
          HellboundEngine.instance.update_trust((get_quest_items_count(pc, LIFE_FORCE) * 80).to_i32, true)
          take_items(pc, LIFE_FORCE, -1)
          html = "32354-11c.htm"
        else
          html = "32354-11d.htm"
        end
      end
    when "clf"
      if HellboundEngine.instance.level == 7
        if has_quest_items?(pc, CONTAINED_LIFE_FORCE)
          HellboundEngine.instance.update_trust((get_quest_items_count(pc, CONTAINED_LIFE_FORCE) * 200).to_i32, true)
          take_items(pc, CONTAINED_LIFE_FORCE, -1)
          html = "32354-11e.htm"
        else
          html = "32354-11f.htm"
        end
      end
    end

    html
  end

  def on_first_talk(npc, pc)
    case HellboundEngine.instance.level
    when 1
      "32354-01.htm"
    when 2, 3
      "32354-01a.htm"
    when 4
      "32354-01e.htm"
    when 5
      "32354-01d.htm"
    when 6
      "32354-01b.htm"
    when 7
      "32354-01c.htm"
    else
      "32354-01f.htm"
    end
  end
end
