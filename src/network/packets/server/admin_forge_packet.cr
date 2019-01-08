class Packets::Outgoing::AdminForgePacket < GameServerPacket
  private record Part, b : Char, str : String

  @parts = [] of Part

  def write_impl
    @parts.each { |p| generate(p.b, p.str) }
  end

  def add_part(b : Char, str : String)
    @parts << Part.new(b, str)
  end

  private def generate(b : Char, string : String) : Bool
    case b
    when 'C', 'c'
      c string.to_i
      true
    when 'D', 'd'
      d string.to_i
      true
    when 'H', 'h'
      h string.to_i
      true
    when 'F', 'f'
      f string.to_f
      true
    when 'S', 's'
      s string
      true
    when 'B', 'b', 'X', 'x'
      b BigInt.new(string).bytes
      true
    when 'Q', 'q'
      q string.to_i64
      true
    else
      false
    end
  end
end
