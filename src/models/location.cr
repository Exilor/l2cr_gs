require "./interfaces/positionable"

class Location
  include Positionable

  property_initializer x : Int32 = 0, y : Int32 = 0, z : Int32 = 0,
    heading : Int32 = 0, instance_id : Int32 = -1

  def initialize(obj : L2Object)
    initialize(*obj.xyz, obj.heading, obj.instance_id)
  end

  def_equals @x, @y, @z, @heading, @instance_id

  def set_xyz(x : Int32, y : Int32, z : Int32)
    self.x, self.y, self.z = x, y, z
  end

  def set_xyz(loc : Locatable)
    set_xyz(*loc.xyz)
  end

  def location : Locatable
    self
  end

  def location=(loc : Location)
    initialize(*loc.xyz, loc.heading, loc.instance_id)
  end

  def to_s(io : IO)
    io << {{@type.stringify + "("}}
    {% for ivar, i in @type.instance_vars %}
      {% if i > 0 %}
        io << ", "
      {% end %}
      io << {{ivar.stringify + ": "}} << @{{ivar.id}}
    {% end %}
    io << ')'
  end
end
