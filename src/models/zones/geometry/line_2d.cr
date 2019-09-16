class Line2D
  def self.lines_intersect?(x1, y1, x2, y2, x3, y3, x4, y4) : Bool
    ((relative_ccw(x1, y1, x2, y2, x3, y3) *
    relative_ccw(x1, y1, x2, y2, x4, y4) <= 0) &&
    (relative_ccw(x3, y3, x4, y4, x1, y1) *
    relative_ccw(x3, y3, x4, y4, x2, y2) <= 0))
  end

  def self.relative_ccw(x1, y1, x2, y2, px, py) : Int32
    x2 -= x1
    y2 -= y1
    px -= x1
    py -= y1

    ccw = px * y2 - py * x2

    if ccw == 0
      ccw = px * x2 + py * y2

      if ccw > 0
        px -= x2
        py -= y2
        ccw = px * x2 + py * y2

        if ccw < 0
          ccw = 0
        end
      end
    end

    ccw < 0 ? -1 : ccw > 0 ? 1 : 0
  end
end
