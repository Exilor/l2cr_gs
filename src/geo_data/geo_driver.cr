require "./i_region"
require "./i_block"
require "./regions/null_region"
require "./regions/region"

class GeoDriver
  include Loggable

  # world dimensions: 1048576 * 1048576 = 1099511627776
  private WORLD_MIN_X = -655360
  private WORLD_MAX_X = 393215
  private WORLD_MIN_Y = -589824
  private WORLD_MAX_Y = 458751

  # Regions in the world on the x axis
  GEO_REGIONS_X = 32
  # Regions in the world on the y axis
  GEO_REGIONS_Y = 32
  # Region in the world
  GEO_REGIONS = GEO_REGIONS_X * GEO_REGIONS_Y

  # Blocks in the world on the x axis
  GEO_BLOCKS_X = GEO_REGIONS_X * IRegion::REGION_BLOCKS_X
  # Blocks in the world on the y axis
  GEO_BLOCKS_Y = GEO_REGIONS_Y * IRegion::REGION_BLOCKS_Y
  # Blocks in the world
  GEO_BLOCKS = GEO_REGIONS * IRegion::REGION_BLOCKS

  # Cells in the world on the x axis
  GEO_CELLS_X = GEO_BLOCKS_X * IBlock::BLOCK_CELLS_X
  # Cells in the world in the y axis
  GEO_CELLS_Y = GEO_BLOCKS_Y * IBlock::BLOCK_CELLS_Y

  @regions = Pointer(IRegion).malloc(GEO_REGIONS, NullRegion.as(IRegion))

  private def check_geo_x(x : Int32)
    if x < 0 || x >= GEO_CELLS_X
      raise ArgumentError.new("Invalid geo x #{x}")
    end
  end

  private def check_geo_y(y : Int32)
    if y < 0 || y >= GEO_CELLS_Y
      raise ArgumentError.new("Invalid geo y #{y}")
    end
  end

  private def get_region(x : Int32, y : Int32) : IRegion
    check_geo_x(x)
    check_geo_y(y)

    @regions[(((x / IRegion::REGION_CELLS_X) * GEO_REGIONS_Y) + (y / IRegion::REGION_CELLS_Y))]
  end

  # Using the file IO to create the region is much slower.
  def load_region(path : String, x : Int32, y : Int32)
    if File.exists?(path)
      offset = (x * GEO_REGIONS_Y) + y
      File.open(path) do |f|
        size = File.info(path).size.to_u32
        slice = GC.malloc_atomic(size).as(UInt8*).to_slice(size)
        f.read_fully(slice)
        io = IO::Memory.new(slice)
        @regions[offset] = Region.new(io)
      end
    end
  end

  def unload_region(x : Int32, y : Int32)
    offset = (x * GEO_REGIONS_Y) + y
    @regions[offset] = NullRegion.as(IRegion)
  end

  def has_geo_pos?(x : Int32, y : Int32) : Bool
    get_region(x, y).has_geo?
  end

  def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    get_region(x, y).check_nearest_nswe(x, y, z, nswe)
  end

  def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
    get_region(x, y).get_nearest_z(x, y, z)
  end

  def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
    get_region(x, y).get_next_lower_z(x, y, z)
  end

  def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
    get_region(x, y).get_next_higher_z(x, y, z)
  end

  def get_geo_x(x : Int32) : Int32
    unless WORLD_MIN_X <= x <= WORLD_MAX_X
      raise ArgumentError.new("x coord #{x} outside of world bounds")
    end

    (x - WORLD_MIN_X) / 16
  end

  def get_geo_y(y : Int32) : Int32
    unless WORLD_MIN_Y <= y <= WORLD_MAX_Y
      raise ArgumentError.new("y coord #{y} outside of world bounds")
    end

    (y - WORLD_MIN_Y) / 16
  end

  def get_world_x(x : Int32) : Int32
    check_geo_x(x)
    (x * 16) + WORLD_MIN_X + 8
  end

  def get_world_y(y : Int32) : Int32
    check_geo_y(y)
    (y * 16) + WORLD_MIN_Y + 8
  end
end
