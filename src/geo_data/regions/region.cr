require "../blocks/flat_block"
require "../blocks/complex_block"
require "../blocks/multilayer_block"

struct Region
  include IRegion

  def initialize(io : IO)
    @blocks = Pointer(IBlock).malloc(REGION_BLOCKS) do
      block_type = io.read_byte
      case block_type
      when IBlock::TYPE_FLAT
        FlatBlock.new(io)
      when IBlock::TYPE_COMPLEX
        ComplexBlock.new(io)
      when IBlock::TYPE_MULTILAYER
        MultilayerBlock.new(io)
      else
        raise "Invalid block type: \"#{block_type}\""
      end
    end
  end

  private def get_block(x : Int32, y : Int32) : IBlock
    @blocks[(((x // IBlock::BLOCK_CELLS_X) % IRegion::REGION_BLOCKS_X) * IRegion::REGION_BLOCKS_Y) + ((y // IBlock::BLOCK_CELLS_Y) % IRegion::REGION_BLOCKS_Y)]
  end

  def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
    get_block(x, y).check_nearest_nswe(x, y, z, nswe)
  end

  def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
    get_block(x, y).get_nearest_z(x, y, z)
  end

  def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
    get_block(x, y).get_next_lower_z(x, y, z)
  end

  def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
    get_block(x, y).get_next_higher_z(x, y, z)
  end

  def has_geo? : Bool
    true
  end
end
