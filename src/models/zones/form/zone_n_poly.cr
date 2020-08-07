require "../geometry/polygon"

struct ZoneNPoly < L2ZoneForm
  @z1 : Int32
  @z2 : Int32

  def initialize(x : Slice(Int32), y : Slice(Int32), z1 : Int32, z2 : Int32)
    @p = Polygon.new(x, y)
    @z1 = Math.min(z1, z2)
    @z2 = Math.max(z1, z2)
  end

  def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
    @p.contains?(x, y) && z.between?(@z1, @z2)
  end

  def intersects_rectangle?(ax1 : Int32, ax2 : Int32, ay1 : Int32, ay2 : Int32) : Bool
    @p.intersects?(
      Math.min(ax1, ax2),
      Math.min(ay1, ay2),
      (ax2 - ax1).abs,
      (ay2 - ay1).abs
    )
  end

  def get_distance_to_zone(x : Int32, y : Int32) : Float64
    _x, _y = @p.x_points, @p.y_points

    shortest_dist = Math.pow(_x[0] - x, 2) + Math.pow(_y[0] - y, 2)
    test = 0.0

    1.upto(@p.n_points &- 1) do |i|
      test = Math.pow(_x[i] - x, 2) + Math.pow(_y[i] - y, 2)
      if test < shortest_dist
        shortest_dist = test
      end
    end

    Math.sqrt(shortest_dist)
  end

  def low_z : Int32
    @z1
  end

  def high_z : Int32
    @z2
  end

  def visualize_zone(z : Int32)
    x, y = @p.x_points, @p.y_points

    @p.n_points.times do |i|
      next_index = i + 1
      if next_index == x.size
        next_index = 0
      end

      vx = x[next_index] - x[i]
      vy = y[next_index] - y[i]

      length = Math.hypot(vx, vy).to_f32 / STEP

      1.upto(length.to_i) do |o|
        k = o.to_f32 / length
        drop_debug_item(
          Inventory::ADENA_ID,
          1,
          (x[i] + (k * vx)).to_i,
          (y[i] + (k * vy)).to_i,
          z
        )
      end
    end
  end

  def random_point : {Int32, Int32, Int32}
    min_x = @p.bounds.x
    max_x = @p.bounds.x + @p.bounds.width
    min_y = @p.bounds.y
    max_y = @p.bounds.y + @p.bounds.height

    x = Rnd.rand(min_x..max_x)
    y = Rnd.rand(min_y..max_y)

    anti_blocker = 0
    while !@p.contains?(x, y) && anti_blocker < 1000
      x = Rnd.rand(min_x..max_x)
      y = Rnd.rand(min_y..max_y)
      anti_blocker &+= 1
    end

    {x, y, GeoData.get_height(x, y, @z1)}
  end
end
