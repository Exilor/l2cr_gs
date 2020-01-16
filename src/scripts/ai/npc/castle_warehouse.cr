class Scripts::CastleWarehouse < AbstractNpcAI
  # NPCs
  private NPCS = {
    35099, # Warehouse Keeper (Gludio)
    35141, # Warehouse Keeper (Dion)
    35183, # Warehouse Keeper (Giran)
    35225, # Warehouse Keeper (Oren)
    35273, # Warehouse Keeper (Aden)
    35315, # Warehouse Keeper (Inadril)
    35362, # Warehouse Keeper (Goddard)
    35508, # Warehouse Keeper (Rune)
    35554  # Warehouse Keeper (Schuttgart)
  }
  # Items
  private BLOOD_OATH = 9910
  private BLOOD_ALLIANCE = 9911

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
    add_first_talk_id(NPCS)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    html = event

    case event
    when "warehouse-01.html", "warehouse-02.html", "warehouse-03.html"
      # do nothing
    when "warehouse-04.html"
      if npc.my_lord?(pc) && (clan = pc.clan)
        html = get_htm(pc, "warehouse-04.html")
        html = html.sub("%blood%", clan.blood_alliance_count.to_s)
      else
        html = "warehouse-no.html"
      end
    when "Receive"
      if !npc.my_lord?(pc)
        html = "warehouse-no.html"
      elsif pc.clan.not_nil!.blood_alliance_count == 0
        html = "warehouse-05.html"
      else
        give_items(pc, BLOOD_ALLIANCE, pc.clan.not_nil!.blood_alliance_count)
        pc.clan.not_nil!.reset_blood_alliance_count
        html = "warehouse-06.html"
      end
    when "Exchange"
      if !npc.my_lord?(pc)
        html = "warehouse-no.html"
      elsif !has_quest_items?(pc, BLOOD_ALLIANCE)
        html = "warehouse-08.html"
      else
        take_items(pc, BLOOD_ALLIANCE, 1)
        give_items(pc, BLOOD_OATH, 30)
        html = "warehouse-07.html"
      end
    else
      html = nil
    end

    html
  end

  def on_first_talk(npc, pc)
    "warehouse-01.html"
  end
end
