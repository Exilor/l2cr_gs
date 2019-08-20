module AdminCommandHandler::AdminGeodata
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    st = command.split
    actual_command = st.shift

    case actual_command.downcase
    when "admin_geo_pos"
      world_x = pc.x
      world_y = pc.y
      world_z = pc.z
      geo_x = GeoData.get_geo_x(world_x)
      geo_y = GeoData.get_geo_y(world_y)

      if GeoData.has_geo_pos?(geo_x, geo_y)
        pc.send_message("world_x: #{world_x}, world_y: #{world_y}, world_z: #{world_z}, geo_x: #{geo_x}, geo_y: #{geo_y}, GeoZ: #{GeoData.get_nearest_z(geo_x, geo_y, world_z)}")
      else
        pc.send_message("There is no geodata at this position.")
      end
    when "admin_geo_spawn_pos"
      world_x = pc.x
      world_y = pc.y
      world_z = pc.z
      geo_x = GeoData.get_geo_x(world_x)
      geo_y = GeoData.get_geo_y(world_y)

      if GeoData.has_geo_pos?(geo_x, geo_y)
        pc.send_message("world_x: #{world_x}, world_y: #{world_y}, world_z: #{world_z}, geo_x: #{geo_x}, geo_y: #{geo_y}, GeoZ: #{GeoData.get_spawn_height(world_x, world_y, world_z)}")
      else
        pc.send_message("There is no geodata at this position.")
      end
    when "admin_geo_can_move"
      if target = pc.target
        if GeoData.can_see_target?(pc, target)
          pc.send_message("Can move beeline.")
        else
          pc.send_message("Cannot move beeline.")
        end
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    when "admin_geo_can_see"
      if target = pc.target
        if GeoData.can_see_target?(pc, target)
          pc.send_message("Can see target.")
        else
          pc.send_packet(SystemMessageId::CANT_SEE_TARGET)
        end
      else
        pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      end
    when "admin_geogrid"
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
