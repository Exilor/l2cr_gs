abstract struct RectangularShape
  abstract def x : Int32
  abstract def y : Int32
  abstract def z : Int32
  abstract def width : Int32
  abstract def height : Int32
  abstract def empty? : Bool
  # abstract def set_frame :

  def min_x : Int32
    x
  end

  def min_y : Int32
    y
  end

  def max_x : Int32
    x &+ width
  end

  def max_y : Int32
    y &+ height
  end

  def center_x : Float64
    (x &+ width) / 2
  end

  def center_y : Float64
    (y &+ height) / 2
  end

  # Unused. Would prevent this hierarchy from being a struct.
  def frame : Rectangle2D
    Rectangle2D.new(x, y, width, height)
  end
end
