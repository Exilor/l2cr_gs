struct ComplexBlock
  include IBlock

  # def initialize(io : IO)
  #   ptr = Pointer(Int16).malloc(BLOCK_CELLS)
  #   tmp = Slice.new(ptr.as(UInt8*), BLOCK_CELLS * 2)
  #   io.read(tmp)
  #   @data = Slice(Int16).new(ptr, BLOCK_CELLS)
  # end

  # def initialize(io : IO)
  #   @data = Pointer(Int16).malloc(BLOCK_CELLS)
  #   tmp = Slice.new(@data.as(UInt8*), BLOCK_CELLS * 2)
  #   io.read(tmp)
  # end

  def initialize(io : IO)
    @data = GC.malloc_atomic(BLOCK_CELLS.to_u32 * 2).as(Int16*)
    slice = @data.as(UInt8*).to_slice(BLOCK_CELLS * 2)
    io.read_fully(slice)
  end

  private def get_cell_data(x : Int32, y : Int32) : Int16
    @data[((x % BLOCK_CELLS_X) * BLOCK_CELLS_Y) + (y % BLOCK_CELLS_Y)]
  end

  private def get_cell_nswe(x : Int32, y : Int32) : Int8
    (get_cell_data(x, y) & 0x000f).to_i8
  end

  private def get_cell_height(x : Int32, y : Int32) : Int32
    (get_cell_data(x, y).to_i64 >> 1).to_i32
  end

  def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    (get_cell_nswe(x, y) & nswe) == nswe
  end

  def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
    get_cell_height(x, y)
  end

  def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
    cell_height = get_cell_height(x, y)
    cell_height <= z ? cell_height : z
  end

  def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
    cell_height = get_cell_height(x, y)
    cell_height >= z ? cell_height : z
  end
end
