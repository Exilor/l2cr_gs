struct MultilayerBlock
  include IBlock

  def initialize(io : IO)
    start = io.pos

    BLOCK_CELLS.times do
      n_layers = io.read_bytes(UInt8)

      unless n_layers.between?(1, 125)
        raise "Corrupted geo file (invalid layers count)"
      end

      io.pos += n_layers &* 2
    end

    size = io.pos &- start
    io.pos = start

    # @data = Slice(UInt8).new(size)
    # io.read(@data)

    @data = GC.malloc_atomic(size).as(UInt8*)
    io.read_fully(@data.to_slice(size))
  end

  private def get_nearest_layer(x : Int32, y : Int32, z : Int32) : Int16
    start_offset = get_cell_data_offset(x, y)
    n_layers = @data[start_offset]
    end_offset = start_offset &+ 1 &+ (n_layers &* 2)

    nearest_dz = 0
    nearest_data = 0i16

    offset = start_offset &+ 1
    while offset < end_offset
      layer_data = extract_layer_data(offset)
      layer_z = extract_layer_height(layer_data)
      if layer_z == z
        return layer_data
      end
      layer_dz = (layer_z - z).abs
      if offset == start_offset &+ 1 || layer_dz < nearest_dz
        nearest_dz = layer_dz
        nearest_data = layer_data
      end

      offset &+= 2
    end

    nearest_data
  end

  private def get_cell_data_offset(x : Int32, y : Int32) : Int32
    local_offset = ((x % BLOCK_CELLS_X) * BLOCK_CELLS_Y) + (y % BLOCK_CELLS_Y)
    data_offset = 0
    local_offset.times { data_offset &+= 1 &+ (@data[data_offset] &* 2) }
    data_offset
  end

  private def extract_layer_data(data_offset : Int32) : Int16
    # IO::ByteFormat::LittleEndian.decode(Int16, @data + data_offset)
    slice = (@data + data_offset).to_slice(2)
    IO::ByteFormat::LittleEndian.decode(Int16, slice)
  end

  private def get_nearest_nswe(x : Int32, y : Int32, z : Int32) : Int32
    extract_layer_nswe(get_nearest_layer(x, y, z))
  end

  private def extract_layer_nswe(layer : Int16) : Int32
    layer.to_i32 & 0x000f
  end

  private def extract_layer_height(layer : Int16) : Int32
    (layer.to_i64 >> 1).to_i32
  end

  def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    (get_nearest_nswe(x, y, z) & nswe) == nswe
  end

  def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
    extract_layer_height(get_nearest_layer(x, y, z))
  end

  def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
    start_offset = get_cell_data_offset(x, y)
    n_layers = @data[start_offset]
    end_offset = start_offset &+ 1 &+ (n_layers &* 2)

    lower_z = Int32::MIN
    offset = start_offset &+ 1
    while offset < end_offset
      layer_data = extract_layer_data(offset)
      layer_z = extract_layer_height(layer_data)
      if layer_z == z
        return layer_z
      end
      if layer_z < z && layer_z > lower_z
        lower_z = layer_z
      end
      offset &+= 2
    end

    lower_z == Int32::MIN ? z : lower_z
  end

  def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
    start_offset = get_cell_data_offset(x, y)
    n_layers = @data[start_offset]
    end_offset = start_offset &+ 1 &+ (n_layers &* 2)

    higher_z = Int32::MAX

    offset = start_offset &+ 1
    while offset < end_offset
      layer_data = extract_layer_data(offset)
      layer_z = extract_layer_height(layer_data)
      if layer_z == z
        return layer_z
      end
      if layer_z > z && layer_z < higher_z
        higher_z = layer_z
      end
      offset &+= 2
    end

    higher_z == Int32::MAX ? z : higher_z
  end
end
