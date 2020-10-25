require "./interfaces/positionable"

struct XYZ
  include Positionable

  property_initializer x : Int32, y : Int32, z : Int32

  def initialize(x : Int32, y : Int32, z : Int32, heading : Int32, instance_id : Int32)
    initialize(x, y, z)
  end

  def initialize(x : Int32, y : Int32, z : Int32, heading : Int32)
    initialize(x, y, z)
  end

  def initialize(loc)
    initialize(loc.x, loc.y, loc.z)
  end

  def heading : Int32
    0
  end

  def heading=(heading : Int32)
    # no-op
  end

  def instance_id : Int32
    -1
  end

  def instance_id=(instance_id : Int32)
    # no-op
  end

  def set_xyz(x : Int32, y : Int32, z : Int32)
    initialize(x, y, z)
  end

  def location : Locatable
    self
  end

  def location=(location : Location)
    initialize(location)
  end
end
