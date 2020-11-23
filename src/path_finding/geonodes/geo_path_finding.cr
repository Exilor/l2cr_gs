require "./geo_node"

module GeoPathFinding
  extend self
  extend Loggable

  private PATH_NODES = {} of Int32 => Slice(UInt8)
  private PATH_NODES_INDEX = {} of Int32 => Slice(Int32)

  def load
    debug "Loading path nodes..."
    timer = Timer.new

    Dir.glob(Config.pathnode_dir + "/*.pn") do |path|
      base_name = File.basename(path, ".pn")
      parts = base_name.split('_')
      unless parts.size == 2 && parts.all? &.number?
        raise "Invalid path node file name '#{base_name}'"
      end
      rx, ry = parts.map &.to_i8
      load_path_node_file(rx, ry)
    end

    debug { "Path nodes loaded in #{timer} s." }
  end

  private def load_path_node_file(rx, ry)
    unless rx.between?(L2World::TILE_X_MIN, L2World::TILE_X_MAX)
      error { "Pathnode file x outside world bounds (#{rx})" }
      return
    end
    unless ry.between?(L2World::TILE_Y_MIN, L2World::TILE_Y_MAX)
      error { "Pathnode file y outside world bounds (#{ry})" }
      return
    end

    offset = get_region_offset(rx, ry).to_i32

    path = "#{Config.pathnode_dir}/#{rx}_#{ry}.pn"
    unless File.file?(path)
      raise "File #{path} not found"
    end

    index = 0

    size = File.size(path)
    slice = GC.malloc_atomic(size).as(UInt8*).to_slice(size)
    File.open(path, &.read_fully(slice))
    indexes = Slice(Int32).new(65536)

    65536.times do |node|
      layer = slice[index]
      indexes[node] = index
      index += (layer.to_i32 * 10) + 1
    end

    PATH_NODES_INDEX[offset] = indexes
    PATH_NODES[offset] = slice
  end

  def path_nodes_exist?(region_offset : Int16) : Bool
    PATH_NODES_INDEX.has_key?(region_offset)
  end

  def find_path(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id : Int32, playable : Bool) : Deque(AbstractNodeLoc)?
    gx = (x - L2World::MAP_MIN_X) >> 4
    gy = (y - L2World::MAP_MIN_Y) >> 4
    gz = z.to_i16!
    gtx = (tx - L2World::MAP_MIN_X) >> 4
    gty = (ty - L2World::MAP_MIN_Y) >> 4
    gtz = tz.to_i16!

    start = read_node(gx, gy, gz)
    stop = read_node(gtx, gty, gtz)

    unless start && stop
      # debug "!(start && stop)"
      return
    end

    if (start.loc.z - z).abs > 55
      # wrong layer
      # debug "!(start.loc.z - z).abs > 55 (#{(start.loc.z - z).abs})"
      return
    end

    if (stop.loc.z - tz).abs > 55
      # wrong layer
      # debug "!(stop.loc.z - tz).abs > 55 (#{(stop.loc.z - tz).abs})"
      return
    end

    if start == stop
      # debug "start == stop"
      return
    end

    temp = GeoData.move_check(x, y, z, start.loc.x, start.loc.y, start.loc.z, instance_id)
    if temp.x != start.loc.x || temp.y != start.loc.y
      # debug "temp.x != start.loc.x || temp.y != start.loc.y"
      return
    end

    temp = GeoData.move_check(tx, ty, tz, stop.loc.x, stop.loc.y, stop.loc.z, instance_id)
    if temp.x != stop.loc.x || temp.y != stop.loc.y
      # debug "temp.x != stop.loc.x || temp.y != stop.loc.y"
      return
    end

    search_by_closest2(start, stop)
  end

  def search_by_closest2(start : GeoNode, stop : GeoNode) : Deque(AbstractNodeLoc)?
    visited = Array(GeoNode).new(550)
    to_visit = [start] of GeoNode

    target_x : Int32 = stop.loc.node_x
    target_y : Int32 = stop.loc.node_y

    i = 0
    while i < 550
      unless node = to_visit.shift?
        # debug "to_visit.shift? == nil"
        return
      end
      if node == stop
        return construct_path2(node)
      end
      i &+= 1

      visited << node
      node.attach_neighbors(read_neighbors(node))
      next unless neighbors = node.neighbors

      neighbors.each do |n|
        if !visited.rindex(n) && !to_visit.includes?(n)
          added = false
          n.parent = node
          dx = target_x - n.loc.node_x
          dy = target_y - n.loc.node_y
          n.cost = dx.abs2 + dy.abs2

          index = 0
          while index < to_visit.size
            if to_visit.unsafe_fetch(index).cost > n.cost
              to_visit.insert(index, n)
              added = true
              break
            end
            index &+= 1
          end

          unless added
            to_visit << n
          end
        end
      end
    end

    nil
  end

  def construct_path2(node : AbstractNode(GeoNodeLoc)) : Deque(AbstractNodeLoc)
    path = Deque(AbstractNodeLoc).new
    previous_direction_x : Int32 = -1000
    previous_direction_y : Int32 = -1000

    while node.parent?
      direction_x : Int32 = node.loc.node_x - node.parent.loc.node_x
      direction_y : Int32 = node.loc.node_y - node.parent.loc.node_y

      if direction_x != previous_direction_x || direction_y != previous_direction_y
        previous_direction_x = direction_x
        previous_direction_y = direction_y
        path.unshift(node.loc)
      end

      node = node.parent
    end

    path
  end

  private def read_neighbors(n : GeoNode) : Array(GeoNode)?
    return unless loc = n.loc?

    idx = n.neighbors_idx
    node_x = loc.node_x
    node_y = loc.node_y

    reg_offset = get_region_offset(get_region_x(node_x), get_region_y(node_y))
    pn = PATH_NODES[reg_offset]

    neighbors = Array(GeoNode).new(8)
    neighbor = pn[idx].to_i8 # N
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = node_x.to_i16
      new_node_y = (node_y &- 1).to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbor = pn[idx].to_i8 # NE
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = (node_x &+ 1).to_i16
      new_node_y = (node_y &- 1).to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbor = pn[idx].to_i8 # E
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = (node_x &+ 1).to_i16
      new_node_y = node_y.to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbor = pn[idx].to_i8 # SE
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = (node_x &+ 1).to_i16
      new_node_y = (node_y &+ 1).to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbor = pn[idx].to_i8 # S
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = node_x.to_i16
      new_node_y = (node_y &+ 1).to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbor = pn[idx].to_i8 # SW
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = (node_x &- 1).to_i16
      new_node_y = (node_y &+ 1).to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbor = pn[idx].to_i8 # W
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = (node_x &- 1).to_i16
      new_node_y = node_y.to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbor = pn[idx].to_i8 # SW
    idx += 1

    if neighbor > 0
      neighbor &-= 1
      new_node_x = (node_x &- 1).to_i16
      new_node_y = (node_y &- 1).to_i16
      if new_node = read_node(new_node_x, new_node_y, neighbor)
        neighbors << new_node
      end
    end

    neighbors
  end

  private def read_node(node_x : Int16, node_y : Int16, layer : Int8) : GeoNode?
    offset = get_region_offset(get_region_x(node_x.to_i32), get_region_y(node_y.to_i32))
    unless path_nodes_exist?(offset)
      debug { "Path nodes do not exist for offset #{offset} (1)" }
      return
    end

    nbx : Int16 = get_node_block(node_x.to_i32)
    nby : Int16 = get_node_block(node_y.to_i32)
    tmp = PATH_NODES_INDEX[offset]
    idx : Int32 = tmp[(nby.to_i32 << 8) &+ nbx]
    pn = PATH_NODES[offset]
    nodes = pn[idx].to_i8
    idx += (layer.to_i32 &* 10) &+ 1
    if nodes < layer
      debug "Something wrong with #read_node(Int16, Int16, Int8)"
    end
    node_z = IO::ByteFormat::BigEndian.decode(Int16, pn + idx)
    idx &+= 2

    GeoNode.new(GeoNodeLoc.new(node_x, node_y, node_z), idx)
  end

  private def read_node(gx : Int32, gy : Int32, z : Int16) : GeoNode?
    node_x : Int16 = get_node_pos(gx)
    node_y : Int16 = get_node_pos(gy)
    reg_x = get_region_x(node_x.to_i32)
    reg_y = get_region_y(node_y.to_i32)
    offset : Int16 = get_region_offset(reg_x, reg_y)

    unless path_nodes_exist?(offset)
      debug { "Path nodes do not exist for offset #{offset} (2)" }
      return
    end

    nbx : Int16 = get_node_block(node_x.to_i32)
    nby : Int16 = get_node_block(node_y.to_i32)

    tmp = PATH_NODES_INDEX[offset]
    idx : Int32 = tmp[(nby.to_i32 << 8) &+ nbx]
    pn = PATH_NODES[offset]

    nodes = pn[idx].to_i8
    idx &+= 1

    idx2 = 0
    last_z = Int16::MIN
    while nodes > 0
      node_z = IO::ByteFormat::BigEndian.decode(Int16, pn + idx)
      if (last_z - z).abs > (node_z - z).abs
        last_z = node_z
        idx2 = idx &+ 2
      end
      idx &+= 10
      nodes &-= 1
    end

    GeoNode.new(GeoNodeLoc.new(node_x, node_y, last_z), idx2)
  end

  delegate get_region_offset, get_node_pos, get_region_x, get_region_y,
    get_node_block, to: PathFinding
end
