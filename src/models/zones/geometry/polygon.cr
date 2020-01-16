require "./crossings"

class Polygon
  @bounds : Rectangle?

  getter x_points : Slice(Int32)
  getter y_points : Slice(Int32)
  getter n_points : Int32

  def initialize(@x_points, @y_points, @n_points = x_points.size)
  end

  def contains?(arg)
    contains?(arg.x, arg.y)
  end

  def contains?(x, y)
    x = x.to_f # this is apparently crucial
    y = y.to_f # this is apparently crucial

    if @n_points <= 2 || !bounding_box.contains?(x, y)
      return false
    end

    hits = 0
    last_x = @x_points[-1]
    last_y = @y_points[-1]

    i = cur_x = cur_y = 0
    while i < @n_points
      cur_x = @x_points[i]
      cur_y = @y_points[i]
      if cur_y == last_y
        i += 1
        last_x = cur_x
        last_y = cur_y
        next
      end
      if cur_x < last_x
        if x >= last_x
          i += 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        left_x = cur_x
      else
        if x >= cur_x
          i += 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        left_x = last_x
      end

      if cur_y < last_y
        if y < cur_y || y >= last_y
          i += 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        if x < left_x
          hits += 1
          i += 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        test_1 = x - cur_x
        test_2 = y - cur_y
      else
        if y < last_y || y >= cur_y
          i += 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        if x < left_x
          hits += 1
          i += 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        test_1 = x - last_x
        test_2 = y - last_y
      end

      if test_1 < test_2 / (last_y - cur_y) * (last_x - cur_x)
        hits += 1
      end

      i += 1
      last_x = cur_x
      last_y = cur_y
    end

    hits & 1 != 0
  end

  def intersects?(arg)
    intersects?(arg.x, arg.y, arg.width, arg.height)
  end

  def intersects?(x, y, w, h)
    x = x.to_f
    y = y.to_f
    w = w.to_f
    h = h.to_f

    if @n_points <= 0 || !bounding_box.intersects?(x, y, w, h)
      false
    else
      cross = get_crossings(x, y, x + w, y + h)
      cross.nil? || !cross.empty?
    end
  end

  def bounding_box
    if @n_points == 0
      Rectangle.new(0, 0)
    else
      unless @bounds
        calculate_bounds(@x_points, @y_points, @n_points)
      end
      @bounds.not_nil!.bounds
    end
  end

  def bounds
    bounding_box
  end

  def calculate_bounds(xpoints, ypoints, npoints)
    bounds_min_x = Int32::MAX
    bounds_min_y = Int32::MAX
    bounds_max_x = Int32::MIN
    bounds_max_y = Int32::MIN

    npoints.times do |i|
      x = xpoints[i]
      bounds_min_x = Math.min(bounds_min_x, x)
      bounds_max_x = Math.max(bounds_max_x, x)

      y = ypoints[i]
      bounds_min_y = Math.min(bounds_min_y, y)
      bounds_max_y = Math.max(bounds_max_y, y)
    end

    @bounds = Rectangle.new(
      bounds_min_x,
      bounds_min_y,
      bounds_max_x - bounds_min_x,
      bounds_max_y - bounds_min_y
    )
  end

  private def get_crossings(xlo, ylo, xhi, yhi)
    cross = Crossings::EvenOdd.new(xlo, ylo, xhi, yhi)
    lastx = @x_points[-1]
    lasty = @y_points[-1]

    @n_points.times do |i|
      curx = @x_points[i]
      cury = @y_points[i]
      if cross.accumulate_line(lastx, lasty, curx, cury)
        return
      end
      lastx = curx
      lasty = cury
    end

    cross
  end
end
