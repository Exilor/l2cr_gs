class L2Territory
  include Loggable

  private record Point, x : Int32, y : Int32, z_min : Int32, z_max : Int32,
    proc : Int32

  @points = [] of Point
  getter proc_max = 0

  def initialize(@terr : Int32) # Integer
    @x_min = @y_min = @z_min = 999999
    @x_max = @y_max = @z_max = -999999
    @points = [] of Point
  end

  def add(x : Int32, y : Int32, z_min : Int32, z_max : Int32, proc : Int32)
    @points << Point.new(x, y, z_min, z_max, proc)
    @x_min = x if x < @x_min
    @y_min = y if y < @y_min
    @x_max = x if x > @x_max
    @y_max = y if y > @y_max
    @z_min = z_min if z_min < @z_min
    @z_max = z_max if z_max > @z_max
    @proc_max += proc
  end

  def intersects?(x : Int32, y : Int32, p1 : Point, p2 : Point) : Bool
    dy1 = p1.y - y
    dy2 = p2.y - y

    if (dy1.sign - dy2.sign).abs <= 1e-6
      return false
    end

    dx1 = (p1.x - x).to_f
    dx2 = (p2.x - x).to_f

    if dx1 >= 0 && dx2 >= 0
      return true
    end

    if dx1 < 0 && dx2 < 0
      return true
    end

    dx0 = (dy1 * (p1.x - p2.x)) / (p1.y - p2.y)
    dx0 <= dx1
  end

  def inside?(x : Int32, y : Int32) : Bool
    intersect_count = 0
    @points.size.times do |i|
      p1 = @points[i > 0 ? i - 1 : -1]
      p2 = @points[i]

      if intersects?(x, y, p1, p2)
        intersect_count += 1
      end
    end
    intersect_count % 2 == 1
  end

  def random_point : Location?
    if @proc_max > 0
      pos = 0
      rnd = Rnd.rand(@proc_max)
      @points.each do |p1|
        pos += p1.proc
        if rnd <= pos
          return Location.new(p1.x, p1.y, Rnd.rand(p1.z_min..p1.z_max))
        end
      end
    end

    100.times do |i|
      x = Rnd.rand(@x_min..@x_max)
      y = Rnd.rand(@y_min..@y_max)

      if inside?(x, y)
        cur_distance = 0
        z_min = @z_min
        @points.each do |p1|
          dx = p1.x - x
          dy = p1.y - y
          distance = Math.hypot(dx, dy)
          if cur_distance == 0 || distance < cur_distance
            cur_distance = distance
            z_min = p1.z_min
          end
        end

        return Location.new(x, y, Rnd.rand(z_min..@z_max))
      end
    end

    warn "Can't make point for territory #{@terr}."

    nil
  end
end
