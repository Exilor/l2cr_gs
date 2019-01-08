class GeoNodeLoc < AbstractNodeLoc
  def_equals @x, @y, @z

  initializer x: Int16, y: Int16, z: Int16

  def x : Int32
    L2World::MAP_MIN_X + (@x.to_i32 * 128) + 48
  end

  def y : Int32
    L2World::MAP_MIN_Y + (@y.to_i32 * 128) + 48
  end

  def z : Int32
    @z.to_i32
  end

  def z=(z : Int16)
    # no-op
  end

  def node_x : Int32
    @x.to_i32
  end

  def node_y : Int32
    @y.to_i32
  end
end
