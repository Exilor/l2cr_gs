require "../geometry/rectangle"

struct ZoneCuboid < L2ZoneForm
  @z1 : Int32
  @z2 : Int32

  def initialize(x1 : Int32, x2 : Int32, y1 : Int32, y2 : Int32, z1 : Int32, z2 : Int32)
    _x1 = Math.min(x1, x2)
    _x2 = Math.max(x1, x2)
    _y1 = Math.min(y1, y2)
    _y2 = Math.max(y1, y2)
    @z1 = Math.min(z1, z2)
    @z2 = Math.max(z1, z2)
    @r = Rectangle.new(_x1, _y1, _x2 - _x1, _y2 - _y1)
  end

  def inside_zone?(x : Int32, y : Int32, z : Int32) : Bool
    @r.contains?(x.to_f64, y.to_f64) && z.between?(@z1, @z2)
  end

  def intersects_rectangle?(ax1 : Int32, ax2 : Int32, ay1 : Int32, ay2 : Int32) : Bool
    @r.intersects?(
      Math.min(ax1, ax2).to_f64,
      Math.min(ay1, ay2).to_f64,
      (ax2 - ax1).abs.to_f64,
      (ay2 - ay1).abs.to_f64
    )
  end

  def get_distance_to_zone(x : Int32, y : Int32) : Float64
    _x1 = @r.x
    _x2 = @r.x + @r.width
    _y1 = @r.y
    _y2 = @r.y + @r.height
    shortest_dist = Math.pow(_x1 - x, 2) + Math.pow(_y1 - y, 2)

    test = Math.pow(_x1 - x, 2) + Math.pow(_y2 - y, 2)
    if test < shortest_dist
      shortest_dist = test
    end

    test = Math.pow(_x2 - x, 2) + Math.pow(_y1 - y, 2)
    if test < shortest_dist
      shortest_dist = test
    end

    test = Math.pow(_x2 - x, 2) + Math.pow(_y2 - y, 2)
    if test < shortest_dist
      shortest_dist = test
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
    _x1 = @r.x
    _x2 = @r.x + @r.width
    _y1 = @r.y
    _y2 = @r.y + @r.height

    _x1.step(to: _x2 - 1, by: STEP) do |x|
      drop_debug_item(Inventory::ADENA_ID, 1, x, _y1, z);
      drop_debug_item(Inventory::ADENA_ID, 1, x, _y2, z);
    end

    _y1.step(to: _y2 - 1, by: STEP) do |y|
      drop_debug_item(Inventory::ADENA_ID, 1, _x1, y, z);
      drop_debug_item(Inventory::ADENA_ID, 1, _x2, y, z);
    end
  end

  def random_point : {Int32, Int32, Int32}
    x = Rnd.rand(@r.x..@r.x + @r.width)
    y = Rnd.rand(@r.y..@r.y + @r.height)
    {x, y, GeoData.get_height(x, y, @z1)}
  end
end
