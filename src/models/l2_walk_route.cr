require "./l2_npc_walker_node"

struct L2WalkRoute
  getter name, node_list, repeat_type
  getter? repeat_walk

  def initialize(@name : String, @node_list : Array(L2NpcWalkerNode), repeat : Bool, once : Bool, @repeat_type : Int8)
    @repeat_walk = repeat_type >= 0 && repeat_type <= 2 ? repeat : false
  end

  def last_node : L2NpcWalkerNode
    @node_list.last
  end

  def nodes_count : Int32
    @node_list.size
  end
end
