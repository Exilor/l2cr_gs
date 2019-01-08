struct FlatBlock
  include IBlock

  def initialize(io : IO)
    @height = Int16.from_io(io, IO::ByteFormat::LittleEndian)
  end

  def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    true
  end

  def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
    @height.to_i32
  end

  def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
    @height <= z ? @height.to_i32 : z
  end

  def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
    @height >= z ? @height.to_i32 : z
  end
end
