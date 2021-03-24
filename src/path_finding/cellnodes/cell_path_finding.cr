require "./cell_node_buffer"

module CellPathFinding
  extend self
  include Loggable

  private ALL_BUFFERS = [] of BufferInfo

  def load
    Config.pathfind_buffers.split(';') do |buf|
      args = buf.split('x')
      if args.size != 2
        raise "Invalid buffer definition: " + buf
      end
      ALL_BUFFERS << BufferInfo.new(args.first.to_i, args.last.to_i)
    end
  end

  def path_nodes_exist?(region_offset)
    false
  end

  def find_path(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32, instance_id : Int32, playable : Bool) : Deque(AbstractNodeLoc)?
    gx = GeoData.get_geo_x(x)
    gy = GeoData.get_geo_y(y)
    unless GeoData.has_geo?(x, y)
      return
    end
    gz = GeoData.get_height(x, y, z)

    gtx = GeoData.get_geo_x(tx)
    gty = GeoData.get_geo_y(ty)
    unless GeoData.has_geo?(tx, ty)
      return
    end
    gtz = GeoData.get_height(tx, ty, tz)

    buffer = alloc(64 &+ (2 &* Math.max((gx &- gtx).abs, (gy &- gty).abs)))
    unless buffer
      return
    end

    begin
      result = buffer.find_path(gx, gy, gz, gtx, gty, gtz)

      unless result
        return
      end

      path = construct_path(result)
    rescue e
      error e
      return
    ensure
      buffer.free
    end

    if path.size < 3 || Config.max_postfilter_passes <= 0
      return path
    end

    pass = 0

    loop do
      pass &+= 1
      remove = false
      current_x = x
      current_y = y
      current_z = z
      mid_point = 0

      while loc_end = path[mid_point &+ 1]?
        loc_middle = path[mid_point]
        if GeoData.can_move?(current_x, current_y, current_z, loc_end.x, loc_end.y, loc_end.z, instance_id)
          path.delete_at(mid_point)
          remove = true
        else
          current_x = loc_middle.x
          current_y = loc_middle.y
          current_z = loc_middle.z
          mid_point &+= 1
        end
      end

      unless playable && remove && path.size > 2 && pass < Config.max_postfilter_passes
        break
      end
    end

    path
  end

  private def construct_path(node : AbstractNode) : Deque(AbstractNodeLoc)
    path = Deque(AbstractNodeLoc).new

    previous_direction_x = Int32::MIN
    previous_direction_y = Int32::MIN
    direction_x = direction_y = 0

    while parent = node.parent?
      if !Config.advanced_diagonal_strategy && (grandparent = parent.parent?)
        tmp_x = node.loc.node_x - grandparent.loc.node_x
        tmp_y = node.loc.node_y - grandparent.loc.node_y

        if tmp_x.abs == tmp_y.abs
          direction_x = tmp_x
          direction_y = tmp_y
        else
          direction_x = node.loc.node_x - parent.loc.node_x
          direction_y = node.loc.node_y - parent.loc.node_y
        end
      else
        direction_x = node.loc.node_x - parent.loc.node_x
        direction_y = node.loc.node_y - parent.loc.node_y
      end

      if direction_x != previous_direction_x || direction_y != previous_direction_y
        previous_direction_x = direction_x
        previous_direction_y = direction_y

        path.unshift(node.loc)
        node.loc = nil
      end

      node = parent
    end

    path
  end

  private def alloc(size)
    current = nil

    ALL_BUFFERS.each do |i|
      if i.map_size >= size
        i.buffers.each do |buf|
          if buf.lock
            current = buf
            break
          end
        end

        break if current

        current = CellNodeBuffer.new(i.map_size)
        current.lock
        if i.buffers.size < i.count
          i.buffers << current
          break
        end
      end
    end

    current
  end

  private struct BufferInfo
    getter buffers = [] of CellNodeBuffer
    getter_initializer map_size : Int32, count : Int32
  end
end
