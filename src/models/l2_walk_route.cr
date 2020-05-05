require "./l2_npc_walker_node"

struct L2WalkRoute
  getter name, node_list, repeat_type
  getter? repeat_walk

  def initialize(name : String, node_list : Array(L2NpcWalkerNode), repeat : Bool, repeat_type : Int8)
    @name = name
    @node_list = node_list
    @repeat_type = repeat_type
    @repeat_walk = repeat_type.between?(0, 2) && repeat
  end

  def last_node : L2NpcWalkerNode
    @node_list.last
  end

  def nodes_count : Int32
    @node_list.size
  end
end
