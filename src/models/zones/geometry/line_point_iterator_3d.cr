struct LinePointIterator3D
  getter x, y, z

  @dx : Int64
  @dy : Int64
  @dz : Int64
  @sx : Int64
  @sy : Int64
  @sz : Int64
  @error : Int64
  @error2 : Int64

  def initialize(@x : Int32, @y : Int32, @z : Int32, @dst_x : Int32, @dst_y : Int32, @dst_z : Int32)
    @dx = (dst_x - x).abs.to_i64
		@dy = (dst_y - y).abs.to_i64
		@dz = (dst_z - z).abs.to_i64
		@sx = x < dst_x ? 1i64 : -1i64
		@sy = y < dst_y ? 1i64 : -1i64
		@sz = z < dst_z ? 1i64 : -1i64

		if @dx >= @dy && @dx >= @dz
			@error = @error2 = @dx // 2
		elsif @dy >= @dx && @dy >= @dz
			@error = @error2 = @dy // 2
		else
			@error = @error2 = @dz // 2
		end

		@first = true
  end

  def next : Bool
    if @first
			@first = false
			return true
    elsif @dx >= @dy && @dx >= @dz
			if @x != @dst_x
				@x += @sx

				@error += @dy
				if @error >= @dx
					@y += @sy
					@error -= @dx
				end

				@error2 += @dz
				if @error2 >= @dx
					@z += @sz
					@error2 -= @dx
				end

				return true
			end
    elsif @dy >= @dx && @dy >= @dz
			if @y != @dst_y
				@y += @sy

				@error += @dx
				if @error >= @dy
					@x += @sx
					@error -= @dy
				end

				@error2 += @dz
				if @error2 >= @dy
					@z += @sz
					@error2 -= @dy
				end

				return true
			end
		else
			if @z != @dst_z
				@z += @sz

				@error += @dx
				if @error >= @dz
					@x += @sx
					@error -= @dz
				end

				@error2 += @dy
				if @error2 >= @dz
					@y += @sy
					@error2 -= @dz
				end

				return true
			end
		end

		false
  end
end
