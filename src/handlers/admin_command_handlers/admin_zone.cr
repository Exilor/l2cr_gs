module AdminCommandHandler::AdminZone
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    st = command.split
    actual_command = st.shift

    if actual_command.casecmp?("admin_zone_check")
      show_html(pc)
      pc.send_message("MapRegion: x:#{MapRegionManager.get_map_region_x(pc.x)} y:#{MapRegionManager.get_map_region_y(pc.y)} (#{MapRegionManager.get_map_region_loc_id(pc)})")
      get_geo_region_xy(pc)
      pc.send_message("Closest Town: " + MapRegionManager.get_closest_town_name(pc))

      loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::CASTLE)
      pc.send_message("TeleToLocation (Castle): x:#{loc.x} y:#{loc.y} z:#{loc.z}")

      loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::CLANHALL)
      pc.send_message("TeleToLocation (ClanHall): x:#{loc.x} y:#{loc.y} z:#{loc.z}")

      loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::SIEGEFLAG)
      pc.send_message("TeleToLocation (SiegeFlag): x:#{loc.x} y:#{loc.y} z:#{loc.z}")

      loc = MapRegionManager.get_tele_to_location(pc, TeleportWhereType::TOWN)
      pc.send_message("TeleToLocation (Town): x:#{loc.x} y:#{loc.y} z:#{loc.z}")
    elsif actual_command.casecmp?("admin_zone_visual")
      _next = st.shift
      if _next.casecmp?("all")
        ZoneManager.get_zones(pc) do |zone|
          zone.visualize_zone(pc.z)
        end
        ZoneManager.get_spawn_territories(pc) do |territory|
          territory.visualize_zone(pc.z)
        end
        show_html(pc)
      else
        zone_id = _next.to_i
        ZoneManager.get_zone_by_id(zone_id).not_nil!.visualize_zone(pc.z)
      end
    elsif actual_command.casecmp?("admin_zone_visual_clear")
      ZoneManager.clear_debug_items
      show_html(pc)
    end

    true
  end

  private def show_html(pc)
    htm_content = HtmCache.get_htm(pc, "data/html/admin/zone.htm").not_nil!
    reply = NpcHtmlMessage.new
    reply.html = htm_content
    reply["%PEACE%"] = pc.inside_peace_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%PVP%"] = pc.inside_pvp_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%SIEGE%"] = pc.inside_siege_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%TOWN%"] = pc.inside_town_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%CASTLE%"] = pc.inside_castle_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%FORT%"] = pc.inside_fort_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%HQ%"] = pc.inside_hq_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%CLANHALL%"] = pc.inside_clan_hall_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%LAND%"] = pc.inside_landing_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%NOLAND%"] = pc.inside_no_landing_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%NOSUMMON%"] = pc.inside_no_summon_friend_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%WATER%"] = pc.inside_water_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%SWAMP%"] = pc.inside_swamp_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%DANGER%"] = pc.inside_danger_area_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%NOSTORE%"] = pc.inside_no_store_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    reply["%SCRIPT%"] = pc.inside_script_zone? ? "<font color=\"LEVEL\">YES</font>" : "NO"
    zones = String.build(100) do |io|
      region = L2World.get_region(pc.x, pc.y)
      region.zones.each do |zone|
        if zone.character_in_zone?(pc)
          if zone_name = zone.name
            io << zone_name << "<br1>"
            if zone.id < 300_000
              io << "(" << zone.id << ")"
            end
          else
            io << zone.id
          end
          io << " "
        end
      end
      ZoneManager.get_spawn_territories(pc) do |territory|
        io << territory.name << "<br1>"
      end
    end
    reply["%ZLIST%"] = zones
    pc.send_packet(reply)
  end

  private def get_geo_region_xy(pc)
    world_x = pc.x
    world_y = pc.y
    geo_x = (((world_x - (-327680)) >> 4) >> 11) + 10
    geo_y = (((world_y - (-262144)) >> 4) >> 11) + 10
    pc.send_message("GeoRegion: #{geo_x}_#{geo_y}")
  end

  def commands : Enumerable(String)
    {
      "admin_zone_check",
      "admin_zone_visual",
      "admin_zone_visual_clear"
    }
  end
end
