class Scripts::Shadai < AbstractNpcAI
  # NPCs
  private SHADAI = 32347
  # Locations
  private DAY_COORDS = Location.new(16882, 238952, 9776)
  private NIGHT_COORDS = Location.new(9064, 253037, -1928)

  def initialize
    super(self.class.simple_name, "hellbound/AI/NPC")
    add_spawn_id(SHADAI)
  end

  def on_adv_event(event, npc, player)
    if event == "VALIDATE_POS" && npc
      coords = DAY_COORDS
      must_revalidate = false
      if npc.x != NIGHT_COORDS.x && GameTimer.night?
        coords = NIGHT_COORDS
        must_revalidate = true
      elsif npc.x != DAY_COORDS.x && !GameTimer.night?
        must_revalidate = true
      end

      if must_revalidate
        npc.spawn.location = coords
        npc.tele_to_location(coords)
      end
    end

    super
  end

  def on_spawn(npc)
    start_quest_timer("VALIDATE_POS", 60_000, npc, nil, true)
    super
  end
end
