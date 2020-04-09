require "./packet"

abstract class MMO::IncomingPacket(T) < MMO::Packet(T)
  private def c : Int32
    buffer.read_bytes(UInt8).to_i32
  end

  private def h : Int32
    buffer.read_bytes(UInt16, BYTE_FORMAT).to_i32
  end

  private def d : Int32
    buffer.read_bytes(Int32, BYTE_FORMAT)
  end

  private def q : Int64
    buffer.read_bytes(Int64, BYTE_FORMAT)
  end

  private def f : Float64
    buffer.read_bytes(Float64, BYTE_FORMAT)
  end

  private def s : String
    offset, count = buffer.pos, 0
    char = h
    until char == 0
      count += 2
      char = h
    end

    String.new((buffer.to_unsafe + offset).to_slice(count), "UTF-16LE")
  end

  private def b(size : Int) : Bytes
    Bytes.new(size).tap { |slice| buffer.read_fully(slice) }
  end

  private def b(slice : Bytes, offset : Int, size : Int)
    buffer.read_fully(slice[offset, size])
  end

  abstract def read : Bool
  abstract def run
end
