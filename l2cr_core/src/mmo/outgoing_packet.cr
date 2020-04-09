require "./packet"

abstract class MMO::OutgoingPacket(T) < MMO::Packet(T)
  private def c(char : Number)
    buffer.write_byte(char.to_u8!)
  end

  private def h(short : Number)
    buffer.write_bytes(short.to_i16!, BYTE_FORMAT)
  end

  private def d(int : Number)
    buffer.write_bytes(int.to_i32!, BYTE_FORMAT)
  end

  private def q(long : Number)
    buffer.write_bytes(long.to_i64!, BYTE_FORMAT)
  end

  private def f(float : Number)
    buffer.write_bytes(float.to_f64!, BYTE_FORMAT)
  end

  private def s(string : String?)
    if string
      buffer.print(string)
    end

    h 0
  end

  private def b(bytes : Bytes)
    buffer.write(bytes)
  end

  abstract def write
end
