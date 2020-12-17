struct ZoneCylinder < L2ZoneForm
  @x : Int32
  @y : Int32
  @z1 : Int32
  @z2 : Int32
  @rad : Int32
  @rad_s : Int32

  def initialize(x : Int32, y : Int32, z1 : Int32, z2 : Int32, rad : Int32)
    @x = x
    @y = y
    @z1 = z1
    @z2 = z2
    @rad = rad
    @rad_s = rad.abs2
  end

  def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
    !((@x - x).abs2 + (@y - y).abs2 > @rad_s || z < @z1 || z > @z2)
  end

  def intersects_rectangle?(ax1 : Int32, ax2 : Int32, ay1 : Int32, ay2 : Int32) : Bool
    if @x > ax1 && @x < ax2 && @y > ay1 && @y < ay2
      return true
    end

    if Math.pow(ax1 - @x, 2) + Math.pow(ay1 - @y, 2) < @rad_s
      return true
    end
    if Math.pow(ax1 - @x, 2) + Math.pow(ay2 - @y, 2) < @rad_s
      return true
    end
    if Math.pow(ax2 - @x, 2) + Math.pow(ay1 - @y, 2) < @rad_s
      return true
    end
    if Math.pow(ax2 - @x, 2) + Math.pow(ay2 - @y, 2) < @rad_s
      return true
    end

    if @x > ax1 && @x < ax2
      if (@y - ay2).abs < @rad
        return true
      end
      if (@y - ay1).abs < @rad
        return true
      end
    end
    if @y > ay1 && @y < ay2
      if (@x - ax2).abs < @rad
        return true
      end
      if (@x - ax1).abs < @rad
        return true
      end
    end

    false
  end

  def get_distance_to_zone(x : Int32, y : Int32) : Float64
    Math.hypot(@x - x, @y - y) - @rad
  end

  def low_z : Int32
    @z1
  end

  def high_z : Int32
    @z2
  end

  def visualize_zone(z : Int32)
    count = ((2 * Math::PI * @rad) / STEP).to_i
    angle = (2 * Math::PI) / count

    count.times do |i|
      x = (Math.cos(angle * i) * @rad).to_i
      y = (Math.sin(angle * i) * @rad).to_i
      drop_debug_item(Inventory::ADENA_ID, 1, @x + x, @y + y, z)
    end
  end

  def random_point : {Int32, Int32, Int32}
    q = Rnd.rand * 2 * Math::PI
    r = Math.sqrt(Rnd.rand)
    x = ((@rad * r * Math.cos(q)) + @x).to_i
    y = ((@rad * r * Math.sin(q)) + @y).to_i

    {x, y, GeoData.get_height(x, y, @z1)}
  end
end
