# Note: Dummy bytes can't reliably be written by advancing the position
# because doing so doesn't make the buffer grow if it's not big enough.
class ByteBuffer < IO::Memory
  # Returns a Slice containing all the memory allocated in this ByteBuffer.
  # This is unlike #to_slice which respects @bytesize, and more like Java's
  # ByteBuffer.array() method.
  def slice : Bytes
    @buffer.to_slice(@capacity)
  end

  def to_unsafe
    @buffer
  end

  def remaining : Int32
    @bytesize - @pos
  end

  def remaining? : Bool
    remaining > 0
  end

  def compact
    temp = @bytesize - @pos
    @buffer.move_from(@buffer + @pos, temp)
    @pos = 0
    @bytesize = temp
    self
  end

  def limit : Int32
    @bytesize
  end

  def limit=(lim : Int)
    @bytesize = lim.to_i32
  end

  private def check_writeable
    # no-op (always writeable)
  end

  private def check_resizeable
    # no-op (always resizeable)
  end

  protected def check_open
    # no-op (always open)
  end

  def closed? : Bool
    false
  end
end
