require "./cell_node"

class CellNodeBuffer
  include Loggable

  private MAX_ITERATIONS = 3500

  @buffer : Slice(Slice(CellNode?))
  @current : CellNode?

  def initialize(size : Int32)
    @map_size = size
    @buffer = Slice.new(size) { Slice.new(size, nil.as(CellNode?)) }
    @base_x = 0
    @base_y = 0
    @target_x = 0
    @target_y = 0
    @target_z = 0
    @time_stamp = 0i64
    @last_elapsed_time = 0i64
    @lock = Mutex.new
  end

  def lock
    # @lock.try_lock
    true
  end

  def find_path(x : Int32, y : Int32, z : Int32, tx : Int32, ty : Int32, tz : Int32) : CellNode?
    @time_stamp = Time.ms
    @base_x = x + ((tx - x - @map_size) / 2)
    @base_y = y + ((ty - y - @map_size) / 2)
    @target_x = tx
    @target_y = ty
    @target_z = tz
    @current = current = get_node(x, y, z).not_nil!
    current.cost = get_cost(x, y, z, Config.high_weight)

    MAX_ITERATIONS.times do
      if current.loc.node_x == @target_x && current.loc.node_y == @target_y
        if (current.loc.z - @target_z).abs < 64
          return current
        end
      end

      find_neighbors

      current = @current.not_nil!

      unless current.next?
        return
      end

      @current = current.next
    end

    nil
  end

  def free
    @current = nil
    @buffer.each { |ary| ary.each { |buf| buf.try &.free } }
    # @lock.unlock
    @last_elapsed_time = Time.ms - @time_stamp
  end

  def elapsed_time
    @last_elapsed_time
  end

  private def find_neighbors
    if _current.loc.can_go_none?
      return
    end

    x = _current.loc.node_x
    y = _current.loc.node_y
    z = _current.loc.z

    if _current.loc.can_go_east?
      node_e = add_node(x + 1, y, z, false)
    end

    if _current.loc.can_go_south?
      node_s = add_node(x, y + 1, z, false)
    end

    if _current.loc.can_go_west?
      node_w = add_node(x - 1, y, z, false)
    end

    if _current.loc.can_go_north?
      node_n = add_node(x, y - 1, z, false)
    end

    if Config.advanced_diagonal_strategy
      if node_e && node_s
        if node_e.loc.can_go_south? && node_s.loc.can_go_east?
          add_node(x + 1, y + 1, z, true)
        end
      end

      if node_s && node_w
        if node_w.loc.can_go_south? && node_s.loc.can_go_west?
          add_node(x - 1, y + 1, z, true)
        end
      end

      if node_n && node_e
        if node_e.loc.can_go_north? && node_n.loc.can_go_east?
          add_node(x + 1, y - 1, z, true)
        end
      end

      if node_n && node_w
        if node_w.loc.can_go_north? && node_n.loc.can_go_west?
          add_node(x - 1, y - 1, z, true)
        end
      end
    end
  end

  private def get_node(x : Int32, y : Int32, z : Int32) : CellNode?
    ax = x - @base_x
    if ax < 0 || ax >= @map_size
      return
    end

    ay = y - @base_y
    if ay < 0 || ay >= @map_size
      return
    end

    result = @buffer[ax][ay]?

    if result.nil?
      result = CellNode.new(NodeLoc.new(x, y, z))
      @buffer[ax][ay] = result
    elsif !result.in_use?
      result.set_in_use
      if loc = result.loc?
        loc.set(x, y, z)
      else
        result.loc = NodeLoc.new(x, y, z)
      end
    end

    result
  end

  def _current
    @current.not_nil!
  end

  private def add_node(x : Int32, y : Int32, z : Int32, diagonal : Bool) : CellNode?
    return unless new_node = get_node(x, y, z)

    if new_node.cost >= 0
      return new_node
    end

    geo_z = new_node.loc.z
    step_z = (geo_z - _current.loc.z).abs
    weight = diagonal ? Config.diagonal_weight : Config.low_weight

    if !new_node.loc.can_go_all? || step_z > 16
      weight = Config.high_weight
    else
      if high_weight?(x + 1, y, geo_z)
        weight = Config.medium_weight
      elsif high_weight?(x - 1, y, geo_z)
        weight = Config.medium_weight
      elsif high_weight?(x, y + 1, geo_z)
        weight = Config.medium_weight
      elsif high_weight?(x, y - 1, geo_z)
        weight = Config.medium_weight
      end
    end

    new_node.parent = _current
    new_node.cost = get_cost(x, y, geo_z, weight)

    node = _current
    count = 0
    limit = MAX_ITERATIONS * 4

    while node.next? && count < limit
      count += 1
      if node.next.cost > new_node.cost
        new_node.next = node.next
        break
      end

      node = node.next
    end

    if count == limit
      warn "Too long loop detected (cost: #{new_node.cost})."
    end

    node.next = new_node

    new_node
  end

  private def high_weight?(x : Int32, y : Int32, z : Int32) : Bool
    return true unless result = get_node(x, y, z)

    unless result.loc.can_go_all?
      return true
    end

    if (result.loc.z - z).abs > 16
      return true
    end

    false
  end

  private def get_cost(x : Int32, y : Int32, z : Int32, weight : Float32) : Float32
    dx = x - @target_x
    dy = y - @target_y
    dz = z - @target_z

    result = Math.sqrt((dx * dx) + (dy * dy) + ((dz * dz) / 256.0))

    if result > weight
      result += weight
    end

    if result > Float32::MAX
      result = Float32::MAX
    end

    result.to_f32
  end
end
