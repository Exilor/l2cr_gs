class Scripts::CastleTeleporter < AbstractNpcAI
  # Teleporter IDs
  private NPCS = {
    35095, # Mass Gatekeeper (Gludio)
    35137, # Mass Gatekeeper (Dion)
    35179, # Mass Gatekeeper (Giran)
    35221, # Mass Gatekeeper (Oren)
    35266, # Mass Gatekeeper (Aden)
    35311, # Mass Gatekeeper (Innadril)
    35355, # Mass Gatekeeper (Goddard)
    35502, # Mass Gatekeeper (Rune)
    35547  # Mass Gatekeeper (Schuttgart)
  }

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(NPCS)
    add_talk_id(NPCS)
    add_first_talk_id(NPCS)
  end

  def on_adv_event(event, npc, player)
    npc = npc.not_nil!

    if event.casecmp?("teleporter-03.html")
      if npc.script_value?(0)
        siege = npc.castle.siege
        time = siege.in_progress? && siege.control_tower_count == 0 ? 480000 : 30000
        start_quest_timer("teleport", time, npc, nil)
        npc.script_value = 1
      end
      return event
    elsif event.casecmp?("teleport")
      region = MapRegionManager.get_map_region_loc_id(npc.x, npc.y)
      msg = NpcSay.new(npc, Say2::NPC_SHOUT, NpcString::THE_DEFENDERS_OF_S1_CASTLE_WILL_BE_TELEPORTED_TO_THE_INNER_CASTLE)
      msg.add_string_parameter(npc.castle.name)
      npc.castle.oust_all_players
      npc.script_value = 0
      # TODO: Is it possible to get all the players for that region, instead of all players?
      L2World.players.each do |pl|
        if region == MapRegionManager.get_map_region_loc_id(pl)
          pl.send_packet(msg)
        end
      end
    end

    nil
  end

  def on_first_talk(npc, player)
    siege = npc.castle.siege
    if npc.script_value?(0)
      if siege.in_progress? && siege.control_tower_count == 0
        "teleporter-02.html"
      else
        "teleporter-01.html"
      end
    else
      "teleporter-03.html"
    end
  end
end
