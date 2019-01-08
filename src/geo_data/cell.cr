module Cell
  # East NSWE flag
	NSWE_EAST = 1 << 0
	# West NSWE flag
	NSWE_WEST = 1 << 1
	# South NSWE flag
	NSWE_SOUTH = 1 << 2
	# North NSWE flag
	NSWE_NORTH = 1 << 3

	# North-East NSWE flags
	NSWE_NORTH_EAST = NSWE_NORTH | NSWE_EAST
	# North-West NSWE flags
	NSWE_NORTH_WEST = NSWE_NORTH | NSWE_WEST
	# South-East NSWE flags
	NSWE_SOUTH_EAST = NSWE_SOUTH | NSWE_EAST
	# South-West NSWE flags
	NSWE_SOUTH_WEST = NSWE_SOUTH | NSWE_WEST

	# All directions NSWE flags
	NSWE_ALL = NSWE_EAST | NSWE_WEST | NSWE_SOUTH | NSWE_NORTH
end
