class L2ColosseumFence < L2Object
  enum FenceState : UInt8
    HIDDEN
    OPEN
    CLOSED
  end

  def initialize(l2id : Int32, instance_id : Int32, x : Int32, y : Int32, z : Int32, min_z : Int32, max_z : Int32, width : Int32, height : Int32, state : FenceState)
    super(l2id)

    @min_z = min_z
    @max_z = max_z
    @state = state
    @bounds = Rectangle.new(x - (width // 2), y - (height // 2), width, height)
    self.instance_id = instance_id
    set_xyz(x, y, z)
  end

  def initialize(instance_id : Int32, x : Int32, y : Int32, z : Int32, min_z : Int32, max_z : Int32, width : Int32, height : Int32, state : FenceState)
    initialize(IdFactory.next, instance_id, x, y, z, min_z, max_z, width, height, state)
  end

  def send_info(pc : L2PcInstance)
    pc.send_packet(ExColosseumFenceInfo.new(self))
  end

  def fence_x : Int32
    @bounds.x
  end

  def fence_y : Int32
    @bounds.y
  end

  def fence_min_z : Int32
    @min_z
  end

  def fence_max_z : Int32
    @max_z
  end

  def fence_width : Int32
    @bounds.width
  end

  def fence_height : Int32
    @bounds.height
  end

  def fence_state : FenceState
    @state
  end

  def id : Int32
    l2id
  end

  def auto_attackable?(char : L2Character) : Bool
    false
  end

  def inside_fence?(x : Int32, y : Int32, z : Int32) : Bool
    x >= @bounds.x && y >= @bounds.y && z >= @min_z && z <= @max_z &&
      x <= @bounds.x + @bounds.width && y <= @bounds.y + @bounds.height
  end
end

