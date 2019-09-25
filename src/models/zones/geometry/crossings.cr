class Crossings
  @yranges = Slice(Float64).new(10)
  @limit = 0

  getter_initializer xlo : Float64, ylo : Float64, xhi : Float64, yhi : Float64

  def empty? : Bool
    @limit == 0
  end

  def accumulate_line(x0, y0, x1, y1, direction = nil)
    unless direction
      if y0 <= y1
        return accumulate_line(x0, y0, x1, y1, 1)
      else
        return accumulate_line(x1, y1, x0, y0, -1)
      end
    end

    if @yhi <= y0 || @ylo >= y1
      return false
    end
    if x0 >= @xhi && x1 >= @xhi
      return false
    end
    if y0 == y1
      return x0 >= @xlo || x1 >= @xlo
    end
    xstart = ystart = xend = yend = 0.0
    dx = x1 - x0
    dy = y1 - y0
    if y0 < @ylo
      xstart = x0 + (@ylo - y0) * dx / dy
      ystart = @ylo
    else
      xstart = x0
      ystart = y0
    end
    if @yhi < y1
      xend = x0 + (@yhi - y0) * dx / dy
      yend = @yhi
    else
      xend = x1
      yend = y1
    end
    if xstart >= @xhi && xend >= @xhi
      return false
    end
    if xstart > @xlo || xend > @xlo
      return true
    end

    record(ystart, yend, direction)

    false
  end

  class EvenOdd < Crossings
    def covers?(ystart, yend)
      @limit == 2 && @yranges[0] <= ystart && @yranges[1] >= yend
    end

    def record(ystart, yend, direction)
      return if ystart >= yend

      from = 0
      while from < @limit && ystart > @yranges[from + 1]
        from += 2
      end
      to = from
      while from < @limit
        yrlo = @yranges[from]
        from += 1
        yrhi = @yranges[from]
        from += 1
        if yend < yrlo
          @yranges[to] = ystart.to_f64
          to += 1
          @yranges[to] = yend.to_f64
          to += 1
          ystart = yrlo
          yend = yrhi
          next
        end
        yll = ylh = yhl = yhh = 0.0
        if ystart < yrlo
          yll = ystart
          ylh = yrlo
        else
          yll = yrlo
          ylh = ystart
        end
        if yend < yrhi
          yhl = yend
          yhh = yrhi
        else
          yhl = yrhi
          yhh = yend
        end
        if ylh == yhl
          ystart = yll
          yend = yhh
        else
          if ylh > yhl
            ystart = yhl
            yhl = ylh
            ylh = ystart
          end
          if yll != ylh
            @yranges[to] = yll.to_f64
            to += 1
            @yranges[to] = ylh.to_f64
            to += 1
          end
          ystart = yhl
          yend = yhh
        end
        if ystart >= yend
          break
        end
      end

      if to < from && from < @limit
        @yranges[to, @limit - from].copy_from(@yranges[from, @limit - from])
      end
      to += @limit - from
      if ystart < yend
        if to >= @yranges.size
          new_ranges = Slice(Float64).new(to + 10)
          new_ranges.copy_from(@yranges)
          @yranges = new_ranges
        end
        @yranges[to] = ystart.to_f64
        to += 1
        @yranges[to] = ystart.to_f64
        to += 1
      end

      @limit = to
    end
  end
end
