module IRegion
  # Blocks in a region on the x axis
	REGION_BLOCKS_X = 256
	# Blocks in a region on the y axis
	REGION_BLOCKS_Y = 256
	# Blocks in a region
	REGION_BLOCKS = REGION_BLOCKS_X * REGION_BLOCKS_Y

	# Cells in a region on the x axis
	REGION_CELLS_X = REGION_BLOCKS_X * IBlock::BLOCK_CELLS_X
	# Cells in a regioin on the y axis
	REGION_CELLS_Y = REGION_BLOCKS_Y * IBlock::BLOCK_CELLS_Y
	# Cells in a region
	REGION_CELLS = REGION_CELLS_X * REGION_CELLS_Y

  abstract def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
  abstract def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
  abstract def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
  abstract def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
  abstract def has_geo? : Bool
end
