require "./rectangle_2d"

class Rectangle < Rectangle2D
  @x = 0
  @y = 0

  getter_initializer x: Int32, y: Int32, width: Int32, height: Int32
  getter_initializer width: Int32, height: Int32


  def bounds
    Rectangle.new(x, y, width, height)
  end

  def bounds_2d
    Rectangle.new(x, y, width, height)
  end

  def z
    raise "shouldn't call Rectangle#z"
  end
end
