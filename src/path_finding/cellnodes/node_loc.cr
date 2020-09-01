class NodeLoc < AbstractNodeLoc
  def initialize(x : Int32, y : Int32, z : Int32)
    @x = x
    @y = y
    @go_north = GeoData.check_nearest_nswe(x, y, z, NSWE::NORTH)
    @go_east  = GeoData.check_nearest_nswe(x, y, z, NSWE::EAST)
    @go_south = GeoData.check_nearest_nswe(x, y, z, NSWE::SOUTH)
    @go_west  = GeoData.check_nearest_nswe(x, y, z, NSWE::WEST)
    @geo_height = GeoData.get_nearest_z(x, y, z)
  end

  def set(x : Int32, y : Int32, z : Int32)
    initialize(x, y, z)
  end

  def can_go_north? : Bool
    @go_north
  end

  def can_go_east? : Bool
    @go_east
  end

  def can_go_south? : Bool
    @go_south
  end

  def can_go_west? : Bool
    @go_west
  end

  def can_go_none? : Bool
    !@go_north && !@go_east && !@go_south && !@go_west
  end

  def can_go_all? : Bool
    @go_north && @go_east && @go_south && @go_west
  end

  def x : Int32
    GeoData.get_world_x(@x)
  end

  def y : Int32
    GeoData.get_world_y(@y)
  end

  def z : Int32
    @geo_height
  end

  def z=(z : Int16)
    # no-op
  end

  def node_x : Int32
    @x
  end

  def node_y : Int32
    @y
  end
end
