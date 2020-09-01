require "./geo_node_loc"

class GeoNode < AbstractNode(GeoNodeLoc)
  getter cost = 0i16
  getter neighbors : Array(GeoNode)?
  getter neighbors_idx

  def initialize(loc : GeoNodeLoc, neighbors_idx : Int32)
    super(loc)
    @neighbors_idx = neighbors_idx
  end

  def cost=(cost : Int)
    @cost = cost.to_i16
  end

  def attach_neighbors(neighbors : Array(GeoNode)?)
    @neighbors = neighbors
  end
end
