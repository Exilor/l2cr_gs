require "./l2_npc_walker_node"

struct L2WalkRoute
  getter name, node_list, repeat_type
  getter? repeat_walk
  # attr_accessor? :do_once # unused, change to class if becomes used

  def initialize(@name : String, @node_list : Array(L2NpcWalkerNode), repeat : Bool, once : Bool, @repeat_type : Int32)
    @repeat_walk = repeat_type >= 0 && repeat_type <= 2 ? repeat : false
    # @do_once = false
  end

  def last_node
    @node_list.last
  end

  def nodes_count
    @node_list.size
  end
end
