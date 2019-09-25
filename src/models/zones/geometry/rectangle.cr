require "./rectangle_2d"

struct Rectangle < Rectangle2D
  @x = 0
  @y = 0

  getter_initializer x : Int32, y : Int32, width : Int32, height : Int32
  getter_initializer width : Int32, height : Int32


  def bounds : Rectangle
    # Rectangle.new(x, y, width, height)
    self
  end

  def bounds_2d : Rectangle
    # Rectangle.new(x, y, width, height)
    self
  end

  def z : Int32
    raise "shouldn't call Rectangle#z"
  end
end
