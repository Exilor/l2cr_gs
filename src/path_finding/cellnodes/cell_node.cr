require "./node_loc"

class CellNode < AbstractNode(NodeLoc)
  getter? in_use = true
  property cost : Float32 = -1000f32
  property! next : CellNode?

  def set_in_use
    @in_use = true
  end

  def free
    @parent = nil
    @cost = -1000f32
    @in_use = false
    @next = nil
  end
end
