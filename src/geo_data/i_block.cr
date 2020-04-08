module IBlock
  TYPE_FLAT = 0
  TYPE_COMPLEX = 1
  TYPE_MULTILAYER = 2

  # Cells in a block on the x axis
  BLOCK_CELLS_X = 8
  # Cells in a block on the y axis
  BLOCK_CELLS_Y = 8
  # Cells in a block
  BLOCK_CELLS = BLOCK_CELLS_X * BLOCK_CELLS_Y

  abstract def check_nearest_nswe(x : Int32, y : Int32, z : Int32, nswe : Int32) : Bool
  abstract def get_nearest_z(x : Int32, y : Int32, z : Int32) : Int32
  abstract def get_next_lower_z(x : Int32, y : Int32, z : Int32) : Int32
  abstract def get_next_higher_z(x : Int32, y : Int32, z : Int32) : Int32
end
