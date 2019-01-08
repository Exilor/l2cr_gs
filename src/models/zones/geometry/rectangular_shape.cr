abstract class RectangularShape
  abstract def x : Int32
  abstract def y : Int32
  abstract def z : Int32
  abstract def width : Int32
  abstract def height : Int32
  abstract def empty? : Bool
  # abstract def set_frame :

  def min_x
    x
  end

  def min_y
    y
  end

  def max_x
    x + width
  end

  def max_y
    y + height
  end

  def center_x
    (x + width) / 2.0
  end

  def center_y
    (y + height) / 2.0
  end

  def frame
    Rectangle2D.new(x, y, width, height)
  end
end
