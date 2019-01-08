module AdminCommandHandler::AdminGeodata
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    debug "Not implemented."
    if command == "admin_geogrid"
      GeoUtils.debug_grid(pc)
    end

    true
  end

  def commands
    {
      "admin_geo_pos",
      "admin_geo_spawn_pos",
  		"admin_geo_can_move",
  		"admin_geo_can_see",
  		"admin_geogrid"
    }
  end
end
