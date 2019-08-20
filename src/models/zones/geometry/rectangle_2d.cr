require "./rectangular_shape"

abstract struct Rectangle2D < RectangularShape
  def intersects?(x : Float64, y : Float64, w : Float64, h : Float64) : Bool
    if empty? || w <= 0 || h <= 0
      return false
    end

    x0, y0 = x(), y()

    x + w > x0 &&
    y + h > y0 &&
    x < x0 + width &&
    y < y0 + height
  end

  def empty? : Bool
    width <= 0 || height <= 0
  end

  def contains?(x : Float64, y : Float64) : Bool
    x0, y0 = x(), y()

    x >= x0 &&
    y >= y0 &&
    x < x0 + width &&
    y < y0 + height
  end

  def contains?(x : Float64, y : Float64, w : Float64, h : Float64) : Bool
    if empty? || w <= 0 || h <= 0
      return false
    end

    x0, y0 = x(), y()

    x >= x0 &&
    y >= y0 &&
    x + w <= x0 + width &&
    y + h <= y0 + height
  end
end
