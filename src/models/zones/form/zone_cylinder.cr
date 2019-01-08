struct ZoneCylinder < L2ZoneForm
  @x : Int32
  @y : Int32
  @z1 : Int32
  @z2 : Int32
  @rad : Int32
  @rad_s : Int32

  def initialize(@x : Int32, @y : Int32, @z1 : Int32, @z2 : Int32, @rad : Int32)
    @rad_s = rad.abs2
  end

  def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
    !(((@x - x) ** 2) + ((@y - y) ** 2) > @rad_s || z < @z1 || z > @z2)
  end

  def intersects_rectangle?(ax1 : Int32, ax2 : Int32, ay1 : Int32, ay2 : Int32) : Bool
    # Circles point inside the rectangle?
		if @x > ax1 && @x < ax2 && @y > ay1 && @y < ay2
			return true
		end

		# Any point of the rectangle intersecting the Circle?
		if ((ax1 - @x) ** 2) + ((ay1 - @y) ** 2) < @rad_s
			return true
		end
		if ((ax1 - @x) ** 2) + ((ay2 - @y) ** 2) < @rad_s
			return true
		end
		if ((ax2 - @x) ** 2) + ((ay1 - @y) ** 2) < @rad_s
			return true
		end
		if ((ax2 - @x) ** 2) + ((ay2 - @y) ** 2) < @rad_s
			return true
		end

		# Collision on any side of the rectangle?
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
    Math.sqrt(((@x - x) ** 2) + ((@y - y) ** 2) - @rad)
  end

  def low_z
    @z1
  end

  def high_z
    @z2
  end

  def visualize_zone(z)
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
