require "./nswe"

module GeoUtils
  extend self

  def compute_nswe(last_x : Int32, last_y : Int32, x : Int32, y : Int32) : Int32
    if x > last_x
      if y > last_y
        NSWE::SOUTH_EAST
      elsif y < last_y
        NSWE::NORTH_EAST
      else
        NSWE::EAST
      end
    elsif x < last_x
      if y > last_y
        NSWE::SOUTH_WEST
      elsif y < last_y
        NSWE::NORTH_WEST
      else
        NSWE::WEST
      end
    else
      if y > last_y
        NSWE::SOUTH
      elsif y < last_y
        NSWE::NORTH
      else
        raise "something wrong with GeoUtils.compute_nswe"
      end
    end
  end

  def debug_grid(pc : L2PcInstance)
    geo_radius = 10
    blocks_per_packet = 49
    i_block = blocks_per_packet
    i_packet = 0

    exsp = nil
    gd = GeoData
    pc_gx = gd.get_geo_x(pc.x)
    pc_gy = gd.get_geo_y(pc.y)
    (-geo_radius).upto(geo_radius) do |dx|
      (-geo_radius).upto(geo_radius) do |dy|
        if i_block >= blocks_per_packet
          i_block = 0
          if exsp
            i_packet &+= 1
            pc.send_packet(exsp)
          end
          exsp = Packets::Outgoing::ExServerPrimitive.new("DebugGrid_#{i_packet}", pc.x, pc.y, -16000)
        end

        gx = pc_gx &+ dx
        gy = pc_gy &+ dy

        x = gd.get_world_x(gx)
        y = gd.get_world_y(gy)
        z = gd.get_nearest_z(gx, gy, pc.z)

        exsp = exsp.not_nil!
        # north arrow
        col = get_direction_color(gx, gy, z, NSWE::NORTH)
        exsp.add_line(col, x &- 1, y &- 7, z, x &+ 1, y &- 7, z)
        exsp.add_line(col, x &- 2, y &- 6, z, x &+ 2, y &- 6, z)
        exsp.add_line(col, x &- 3, y &- 5, z, x &+ 3, y &- 5, z)
        exsp.add_line(col, x &- 4, y &- 4, z, x &+ 4, y &- 4, z)

        # east arrow
        col = get_direction_color(gx, gy, z, NSWE::EAST)
        exsp.add_line(col, x &+ 7, y &- 1, z, x &+ 7, y &+ 1, z)
        exsp.add_line(col, x &+ 6, y &- 2, z, x &+ 6, y &+ 2, z)
        exsp.add_line(col, x &+ 5, y &- 3, z, x &+ 5, y &+ 3, z)
        exsp.add_line(col, x &+ 4, y &- 4, z, x &+ 4, y &+ 4, z)

        # south arrow
        col = get_direction_color(gx, gy, z, NSWE::SOUTH)
        exsp.add_line(col, x &- 1, y &+ 7, z, x &+ 1, y &+ 7, z)
        exsp.add_line(col, x &- 2, y &+ 6, z, x &+ 2, y &+ 6, z)
        exsp.add_line(col, x &- 3, y &+ 5, z, x &+ 3, y &+ 5, z)
        exsp.add_line(col, x &- 4, y &+ 4, z, x &+ 4, y &+ 4, z)

        col = get_direction_color(gx, gy, z, NSWE::WEST)
        exsp.add_line(col, x &- 7, y &- 1, z, x &- 7, y &+ 1, z)
        exsp.add_line(col, x &- 6, y &- 2, z, x &- 6, y &+ 2, z)
        exsp.add_line(col, x &- 5, y &- 3, z, x &- 5, y &+ 3, z)
        exsp.add_line(col, x &- 4, y &- 4, z, x &- 4, y &+ 4, z)

        i_block &+= 1
      end
    end

    pc.send_packet(exsp.not_nil!)
  end

  private def get_direction_color(x, y, z, nswe)
    GeoData.check_nearest_nswe(x, y, z, nswe) ? :GREEN : :RED
  end
end
