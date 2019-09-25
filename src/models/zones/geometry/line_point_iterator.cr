struct LinePointIterator
  getter x, y

  @dx : Int64
  @dy : Int64
  @sx : Int64
  @sy : Int64
  @error : Int64

  def initialize(@x : Int32, @y : Int32, @dst_x : Int32, @dst_y : Int32)
		@dx = (dst_x - x).abs.to_i64
		@dy = (dst_y - y).abs.to_i64
		@sx = x < dst_x ? 1i64 : -1i64
		@sy = y < dst_y ? 1i64 : -1i64

		if @dx >= @dy
			@error = @dx // 2
		else
			@error = @dy // 2
		end

		@first = true
  end

  def next : Bool
    if @first
			@first = false
			return true
		elsif @dx >= @dy
			if @x != @dst_x
				@x += @sx

				@error += @dy
				if @error >= @dx
					@y += @sy
					@error -= @dx
				end

				return true
			end
		else
			if @y != @dst_y
				@y += @sy

				@error += @dx
				if @error >= @dy
					@x += @sx
					@error -= @dy
				end

				return true
			end
		end

		false
  end
end
