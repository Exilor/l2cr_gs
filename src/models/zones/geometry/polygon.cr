require "./crossings"

class Polygon
  @bounds : Rectangle?

  getter_initializer x_points : Slice(Int32), y_points : Slice(Int32)

  def n_points
    @x_points.size
  end

  def contains?(arg)
    contains?(arg.x, arg.y)
  end

  def contains?(x, y)
    x = x.to_f
    y = y.to_f

    if n_points <= 2 || !bounding_box.contains?(x, y)
      return false
    end

    hits = 0
    last_x = @x_points[-1]
    last_y = @y_points[-1]

    i = cur_x = cur_y = 0
    while i < n_points
      cur_x = @x_points[i]
      cur_y = @y_points[i]
      if cur_y == last_y
        i &+= 1
        last_x = cur_x
        last_y = cur_y
        next
      end
      if cur_x < last_x
        if x >= last_x
          i &+= 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        left_x = cur_x
      else
        if x >= cur_x
          i &+= 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        left_x = last_x
      end

      if cur_y < last_y
        if y < cur_y || y >= last_y
          i &+= 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        if x < left_x
          hits &+= 1
          i &+= 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        test_1 = x - cur_x
        test_2 = y - cur_y
      else
        if y < last_y || y >= cur_y
          i &+= 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        if x < left_x
          hits &+= 1
          i &+= 1
          last_x = cur_x
          last_y = cur_y
          next
        end
        test_1 = x - last_x
        test_2 = y - last_y
      end

      if test_1 < test_2 / (last_y - cur_y) * (last_x - cur_x)
        hits &+= 1
      end

      i &+= 1
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

    if n_points <= 0 || !bounding_box.intersects?(x, y, w, h)
      return false
    end

    cross = get_crossings(x, y, x + w, y + h)
    cross.nil? || !cross.empty?
  end

  def bounding_box
    if n_points == 0
      return Rectangle.new(0, 0)
    end

    (@bounds || calculate_bounds(@x_points, @y_points, n_points)).bounds
  end

  def bounds
    bounding_box
  end

  private def calculate_bounds(xpoints, ypoints, npoints)
    min_x = Int32::MAX
    min_y = Int32::MAX
    max_x = Int32::MIN
    max_y = Int32::MIN

    npoints.times do |i|
      x = xpoints[i]
      min_x = Math.min(min_x, x)
      max_x = Math.max(max_x, x)

      y = ypoints[i]
      min_y = Math.min(min_y, y)
      max_y = Math.max(max_y, y)
    end

    @bounds = Rectangle.new(min_x, min_y, max_x - min_x, max_y - min_y)
  end

  private def get_crossings(xlo, ylo, xhi, yhi)
    cross = Crossings::EvenOdd.new(xlo, ylo, xhi, yhi)
    lastx = @x_points[-1]
    lasty = @y_points[-1]

    n_points.times do |i|
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
