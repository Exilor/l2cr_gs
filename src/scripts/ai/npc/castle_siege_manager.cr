class Scripts::CastleSiegeManager < AbstractNpcAI
  # NPCs
  private SIEGE_MANAGER = {
    35104, # Gludio Castle
    35146, # Dion Castle
    35188, # Giran Castle
    35232, # Oren Castle
    35278, # Aden Castle
    35320, # Innadril Castle
    35367, # Goddard Castle
    35513, # Rune Castle
    35559, # Schuttgard Castle
    35639, # Fortress of the Dead
    35420  # Devastated Castle
  }

  def initialize
    super(self.class.simple_name, "ai/npc")
    add_first_talk_id(SIEGE_MANAGER)
  end

  def on_first_talk(npc, player)
    if player.clan_leader? && player.clan_id == npc.castle.owner_id
      if in_siege?(npc)
        html = "CastleSiegeManager.html"
      else
        html = "CastleSiegeManager-01.html"
      end
    elsif in_siege?(npc)
      html = "CastleSiegeManager-02.html"
    else
      if hall = npc.conquerable_hall?
        hall.show_siege_info(player)
      else
        npc.castle.siege.list_register_clan(player)
      end
    end

    html
  end

  private def in_siege?(npc)
    if (hall = npc.conquerable_hall?) && hall.in_siege?
      return true
    elsif npc.castle.siege.in_progress?
      return true
    end

    false
  end
end
