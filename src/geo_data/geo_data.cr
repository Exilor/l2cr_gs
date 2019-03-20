require "./geo_driver"
require "./geo_utils"
require "../models/zones/geometry/line_point_iterator"
require "../models/zones/geometry/line_point_iterator_3d"

module GeoData
  extend self
  extend Loggable

  private ELEVATED_SEE_OVER_DISTANCE = 2
  private MAX_SEE_OVER_HEIGHT = 48
  private SPAWN_Z_DELTA_LIMIT = 100
  private FILE_NAME_FORMAT = "%d_%d.l2j"

  private class_getter! driver : GeoDriver

  def load
    info "Loading geodata files..."
    @@driver = GeoDriver.new
    loaded_regions = 0
    timer = Timer.new
    geo_path = Config.geodata_path + "/"
    L2World::TILE_X_MIN.upto(L2World::TILE_X_MAX) do |region_x|
      L2World::TILE_Y_MIN.upto(L2World::TILE_Y_MAX) do |region_y|
        file_path = geo_path + sprintf(FILE_NAME_FORMAT, region_x, region_y)
        load_file = Config.geodata_regions["#{region_x}_#{region_y}"]?
        if !load_file.nil?
          if load_file
            debug { "Loading #{File.basename(file_path)}" }
            driver.load_region(file_path, region_x, region_y)
            loaded_regions += 1
          end
        elsif Config.try_load_unspecified_regions && File.exists?(file_path)
          debug { "Loading #{File.basename(file_path)}" }
          driver.load_region(file_path, region_x, region_y)
          loaded_regions += 1
        end
      end
    end

    info "Loaded #{loaded_regions} regions in #{timer.result} s."
  end

  def has_geo_pos?(x : Int32, y : Int32) : Bool
    driver.has_geo_pos?(x, y)
  end

  def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    driver.check_nearest_nswe(x, y, z, nswe)
  end

  def check_nearest_nswe_anti_corner_cut(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    can = true

    if nswe & Cell::NSWE_NORTH_EAST == Cell::NSWE_NORTH_EAST
      can = check_nearest_nswe(x, y - 1, z, Cell::NSWE_EAST) &&
        check_nearest_nswe(x + 1, y, z, Cell::NSWE_NORTH)
    end

    if can && nswe & Cell::NSWE_NORTH_WEST == Cell::NSWE_NORTH_WEST
      can = check_nearest_nswe(x, y - 1, z, Cell::NSWE_WEST) &&
        check_nearest_nswe(x, y - 1, z, Cell::NSWE_NORTH)
    end

    if can && nswe & Cell::NSWE_SOUTH_EAST == Cell::NSWE_SOUTH_EAST
      can = check_nearest_nswe(x, y + 1, z, Cell::NSWE_EAST) &&
        check_nearest_nswe(x + 1, y, z, Cell::NSWE_SOUTH)
    end

    if can && nswe & Cell::NSWE_SOUTH_WEST == Cell::NSWE_SOUTH_WEST
      can = check_nearest_nswe(x, y + 1, z, Cell::NSWE_WEST) &&
        check_nearest_nswe(x - 1, y, z, Cell::NSWE_SOUTH)
    end

    can && check_nearest_nswe(x, y, z, nswe)
  end

  def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
    driver.get_nearest_z(x, y, z)
  end

  def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
    driver.get_next_lower_z(x, y, z)
  end

  def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
    driver.get_next_higher_z(x, y, z)
  end

  def get_geo_x(x : Int32) : Int32
    driver.get_geo_x(x)
  end

  def get_geo_y(y : Int32) : Int32
    driver.get_geo_y(y)
  end

  def get_world_x(x : Int32) : Int32
    driver.get_world_x(x)
  end

  def get_world_y(y : Int32) : Int32
    driver.get_world_y(y)
  end

  def get_height(x : Int32, y : Int32, z : Int32) : Int32
    get_nearest_z(get_geo_x(x), get_geo_y(y), z)
  end

  def get_spawn_height(loc : Location) : Int32
    get_spawn_height(*loc.xyz)
  end

  def get_spawn_height(x : Int32, y : Int32, z : Int32) : Int32
    geo_x, geo_y = get_geo_x(x), get_geo_y(y)

    unless has_geo_pos?(geo_x, geo_y)
      return z
    end

    next_lower_z = get_next_lower_z(geo_x, geo_y, z + 20).to_i

    (next_lower_z - z).abs <= SPAWN_Z_DELTA_LIMIT ? next_lower_z : z
  end

  def can_see_target?(char : L2Object, target : L2Object?) : Bool
    unless target
      return false
    end

    if target.door?
      return true
    end

    can_see_target?(*char.xyz, char.instance_id, *target.xyz, target.instance_id)
  end

  def can_see_target?(char : L2Object, pos : Locatable) : Bool
    can_see_target?(*char.xyz, char.instance_id, *pos.xyz)
  end

  def can_see_target?(x : Int32, y : Int32, z : Int32, instance_id : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id2 : Int32) : Bool
    instance_id == instance_id2 &&
    can_see_target?(x, y, z, instance_id, tx, ty, tz)
  end

  def can_see_target?(x : Int32, y : Int32, z : Int32, instance_id : Int32, tx : Int32, ty : Int32, tz : Int32) : Bool
    !DoorData.check_if_doors_between(x, y, z, tx, ty, tz, instance_id, true) &&
    can_see_target?(x, y, z, tx, ty, tz)
  end

  def can_see_target?(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32) : Bool
    geo_x = get_geo_x(x)
    geo_y = get_geo_y(y)
    t_geo_x = get_geo_x(tx)
    t_geo_y = get_geo_y(ty)

    z = get_nearest_z(geo_x, geo_y, z)
    tz = get_nearest_z(t_geo_x, t_geo_y, tz)

    if geo_x == t_geo_x && geo_y == t_geo_y
      if has_geo_pos?(t_geo_x, t_geo_y)
        return z == tz
      end

      return true
    end

    if tz > z
      tmp = tx
      tx = x
      x = tmp

      tmp = ty
      ty = y
      y = tmp

      tmp = tz
      tz = z
      z = tmp

      tmp = t_geo_x
      t_geo_x = geo_x
      geo_x = tmp

      tmp = t_geo_y
      t_geo_y = geo_y
      geo_y = tmp
    end

    iter = LinePointIterator3D.new(geo_x, geo_y, z, t_geo_x, t_geo_y, tz)
    iter.next

    prev_x = iter.x
    prev_y = iter.y
    prev_z = iter.z
    prev_geo_z = prev_z
    pt_index = 0
    while iter.next
      cur_x = iter.x
      cur_y = iter.y

      if cur_x == prev_x && cur_y == prev_y
        next
      end

      bee_cur_z = iter.z
      cur_geo_z = prev_geo_z

      if has_geo_pos?(cur_x, cur_y)
        nswe = GeoUtils.compute_nswe(prev_x, prev_y, cur_x, cur_y)
        cur_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, cur_x, cur_y, nswe)

        if pt_index < ELEVATED_SEE_OVER_DISTANCE
          max_height = z + MAX_SEE_OVER_HEIGHT
        else
          max_height = bee_cur_z + MAX_SEE_OVER_HEIGHT
        end

        can_see_through = false

        if cur_geo_z <= max_height
          if nswe & Cell::NSWE_NORTH_EAST == Cell::NSWE_NORTH_EAST
            north_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x, prev_y - 1, Cell::NSWE_EAST)
            east_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x + 1, prev_y, Cell::NSWE_NORTH)
            can_see_through = north_geo_z <= max_height && east_geo_z <= max_height && north_geo_z <= get_nearest_z(prev_x, prev_y - 1, bee_cur_z) && east_geo_z <= get_nearest_z(prev_x + 1, prev_y, bee_cur_z)
          elsif nswe & Cell::NSWE_NORTH_WEST == Cell::NSWE_NORTH_WEST
            north_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x, prev_y - 1, Cell::NSWE_WEST)
            west_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x - 1, prev_y, Cell::NSWE_NORTH)
            can_see_through = north_geo_z <= max_height && west_geo_z <= max_height && north_geo_z <= get_nearest_z(prev_x, prev_y - 1, bee_cur_z) && west_geo_z <= get_nearest_z(prev_x - 1, prev_y, bee_cur_z)
          elsif nswe & Cell::NSWE_SOUTH_EAST == Cell::NSWE_SOUTH_EAST
            south_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x, prev_y + 1, Cell::NSWE_EAST)
            east_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x + 1, prev_y, Cell::NSWE_SOUTH)
            can_see_through = south_geo_z <= max_height && east_geo_z <= max_height && south_geo_z <= get_nearest_z(prev_x, prev_y + 1, bee_cur_z) && east_geo_z <= get_nearest_z(prev_x + 1, prev_y, bee_cur_z)
          elsif nswe & Cell::NSWE_SOUTH_WEST == Cell::NSWE_SOUTH_WEST
            south_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x, prev_y + 1, Cell::NSWE_WEST)
            west_geo_z = get_los_geo_z(prev_x, prev_y, prev_geo_z, prev_x - 1, prev_y, Cell::NSWE_SOUTH)
            can_see_through = south_geo_z <= max_height && west_geo_z <= max_height && south_geo_z <= get_nearest_z(prev_x, prev_y + 1, bee_cur_z) && west_geo_z <= get_nearest_z(prev_x - 1, prev_y, bee_cur_z)
          else
            can_see_through = true
          end
        end

        unless can_see_through
          return false
        end
      end

      prev_x = cur_x
      prev_y = cur_y
      prev_geo_z = cur_geo_z
      pt_index += 1
    end

    true
  end

  def can_move?(from : Locatable, to_x : Int32, to_y : Int32, to_z : Int32) : Bool
    can_move?(*from.xyz, to_x, to_y, to_z, from.instance_id)
  end

  def can_move?(from : Locatable, to : Locatable) : Bool
    can_move?(from, *to.xyz)
  end

  def can_move?(from_x : Int32, from_y : Int32, from_z : Int32, to_x : Int32, to_y : Int32, to_z : Int32, instance_id : Int32) : Bool
    geo_x = get_geo_x(from_x)
    geo_y = get_geo_y(from_y)
    from_z = get_nearest_z(geo_x, geo_y, from_z)
    t_geo_x = get_geo_x(to_x)
    t_geo_y = get_geo_y(to_y)
    to_z = get_nearest_z(t_geo_x, t_geo_y, to_z)

    if DoorData.check_if_doors_between(from_x, from_y, from_z, to_x, to_y, to_z, instance_id, false)
      return false
    end

    iter = LinePointIterator.new(geo_x, geo_y, t_geo_x, t_geo_y)
    iter.next
    prev_x = iter.x
    prev_y = iter.y
    prev_z = from_z

    while iter.next
      cur_x = iter.x
      cur_y = iter.y
      curZ = get_nearest_z(cur_x, cur_y, prev_z)

      if has_geo_pos?(prev_x, prev_y)
        nswe = GeoUtils.compute_nswe(prev_x, prev_y, cur_x, cur_y)
        unless check_nearest_nswe_anti_corner_cut(prev_x, prev_y, prev_z, nswe)
          return false
        end
      end

      prev_x = cur_x
      prev_y = cur_y
      prev_z = curZ
    end

    if has_geo_pos?(prev_x, prev_y) && prev_z != to_z
      # different floors
      return false
    end

    true
  end

  private def get_los_geo_z(prev_x : Int32, prev_y : Int32, prev_z : Int32, cur_x : Int32, cur_y : Int32, nswe : Int32) : Int32
    if (((nswe & Cell::NSWE_NORTH) != 0) && ((nswe & Cell::NSWE_SOUTH) != 0)) ||
      (((nswe & Cell::NSWE_WEST) != 0) && ((nswe & Cell::NSWE_EAST) != 0))

      raise "Multiple directions"
    end

    if check_nearest_nswe_anti_corner_cut(prev_x, prev_y, prev_z, nswe)
      get_nearest_z(cur_x, cur_y, prev_z)
    else
      get_next_higher_z(cur_x, cur_y, prev_z)
    end
  end

  def move_check(loc : Locatable, dst : Locatable) : Location
    move_check(*loc.xyz, *dst.xyz, loc.instance_id)
  end

  def move_check(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id : Int32) : Location
    geo_x = get_geo_x(x)
    geo_y = get_geo_y(y)
    z = get_nearest_z(geo_x, geo_y, z)
    t_geo_x = get_geo_x(tx)
    t_geo_y = get_geo_y(ty)
    tz = get_nearest_z(t_geo_x, t_geo_y, tz)

    if DoorData.check_if_doors_between(x, y, z, tx, ty, tz, instance_id, false)
      return Location.new(x, y, get_height(x, y, z))
    end

    iter = LinePointIterator.new(geo_x, geo_y, t_geo_x, t_geo_y)
    iter.next
    prev_x = iter.x
    prev_y = iter.y
    prev_z = z

    while iter.next
      cur_x = iter.x
      cur_y = iter.y
      cur_z = get_nearest_z(cur_x, cur_y, prev_z)

      if has_geo_pos?(prev_x, prev_y)
        nswe = GeoUtils.compute_nswe(prev_x, prev_y, cur_x, cur_y)
        unless check_nearest_nswe_anti_corner_cut(prev_x, prev_y, prev_z, nswe)
          return Location.new(get_world_x(prev_x), get_world_y(prev_y), prev_z)
        end
      end

      prev_x = cur_x
      prev_y = cur_y
      prev_z = cur_z
    end

    if has_geo_pos?(prev_x, prev_y) && prev_z != tz
      Location.new(x, y, z)
    else
      Location.new(tx, ty, tz)
    end
  end

  def has_geo?(x : Int32, y : Int32) : Bool
    has_geo_pos?(get_geo_x(x), get_geo_y(y))
  end
end
