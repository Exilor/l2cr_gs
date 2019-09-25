class Packets::Outgoing::ExServerPrimitive < GameServerPacket
  @points = [] of Point
  @lines = [] of Line

  initializer name : String, x : Int32, y : Int32, z : Int32

  def initialize(name : String, loc : Locatable)
    initialize(name, *loc.xyz)
  end

  def add_point(name : String, color : Symbol, colored : Bool, x : Int32, y : Int32, z : Int32)
    @points << Point.new(name, color, colored, x, y, z)
  end

  def add_point(name : String, color : Int32, colored : Bool, loc : Locatable)
    @points << Point.new(name, color, colored, *loc.xyz)
  end

  def add_point(color : Int32, x : Int32, y : Int32, z : Int32)
    @points << Point.new("", color, false, x, y, z)
  end

  def add_point(color : Int32, loc : Locatable)
    @points << Point.new("", color, false, *loc.xyz)
  end

  def add_point(name : String, color : Symbol, colored : Bool, x : Int32, y : Int32, z : Int32)
    color = get_rgb(color)
    @points << Point.new(name, color, colored, x, y, z)
  end

  def add_point(name : String, color : Symbol, colored : Bool, loc : Locatable)
    color = get_rgb(color)
    @points << Point.new(name, color, colored, *loc.xyz)
  end

  def add_point(color : Symbol, x : Int32, y : Int32, z : Int32)
    color = get_rgb(color)
    @points << Point.new("", color, false, x, y, z)
  end

  def add_point(color : Symbol, loc : Locatable)
    color = get_rgb(color)
    @points << Point.new("", color, false, *loc.xyz)
  end

  def add_line(name : String, color : Int32, colored : Bool, x : Int32, y : Int32, z : Int32, x2 : Int32, y2 : Int32, z2 : Int32)
    @lines << Line.new(name, color, colored, x, y, z, x2, y2, z2)
  end

  def add_line(name, color, colored, loc : Locatable, x2 : Int32, y2 : Int32, z2 : Int32)
    @lines << Line.new(name, color, colored, *loc.xyz, x2, y2, z2)
  end

  def add_line(name : String, color : Int32, colored : Bool, x : Int32, y : Int32, z : Int32, loc)
    @lines << Line.new(name, color, colored, x, y, z, *loc.xyz)
  end

  def add_line(name : String, color : Int32, colored : Bool, loc1 : Locatable, loc2 : Locatable)
    @lines << Line.new(name, color, colored, *loc1.xyz, *loc2.xyz)
  end

  def add_line(color : Int32, x : Int32, y : Int32, z : Int32, x2 : Int32, y2 : Int32, z2 : Int32)
    @lines << Line.new("", color, false, x, y, z, x2, y2, z2)
  end

  def add_line(color : Int32, loc : Locatable, x2 : Int32, y2 : Int32, z2 : Int32)
    @lines << Line.new("", color, false, *loc.xyz, x2, y2, z2)
  end

  def add_line(color : Int32, x : Int32, y : Int32, z : Int32, loc : Locatable)
    @lines << Line.new("", color, false, x, y, z, *loc.xyz)
  end

  def add_line(color : Int32, loc1 : Locatable, loc2 : Locatable)
    @lines << Line.new("", color, false, *loc1.xyz, *loc2.xyz)
  end

  def add_line(name : String, color : Symbol, colored : Bool, x : Int32, y : Int32, z : Int32, x2 : Int32, y2 : Int32, z2 : Int32)
    color = get_rgb(color)
    @lines << Line.new(name, color, colored, x, y, z, x2, y2, z2)
  end

  def add_line(name : String, color : Symbol, colored : Bool, loc : Locatable, x2 : Int32, y2 : Int32, z2 : Int32)
    color = get_rgb(color)
    @lines << Line.new(name, color, colored, *loc.xyz, x2, y2, z2)
  end

  def add_line(name : String, color : Symbol, colored : Bool, x : Int32, y : Int32, z : Int32, loc : Locatable)
    color = get_rgb(color)
    @lines << Line.new(name, color, colored, x, y, z, *loc.xyz)
  end

  def add_line(name : String, color : Symbol, colored : Bool, loc1 : Locatable, loc2 : Locatable)
    color = get_rgb(color)
    @lines << Line.new(name, color, colored, *loc1.xyz, *loc2.xyz)
  end

  def add_line(color : Symbol, x : Int32, y : Int32, z : Int32, x2 : Int32, y2 : Int32, z2 : Int32)
    color = get_rgb(color)
    @lines << Line.new("", color, false, x, y, z, x2, y2, z2)
  end

  def add_line(color : Symbol, loc : Locatable, x2 : Int32, y2 : Int32, z2 : Int32)
    color = get_rgb(color)
    @lines << Line.new("", color, false, *loc.xyz, x2, y2, z2)
  end

  def add_line(color : Symbol, x : Int32, y : Int32, z : Int32, loc : Locatable)
    color = get_rgb(color)
    @lines << Line.new("", color, false, x, y, z, *loc.xyz)
  end

  def add_line(color : Symbol, loc1 : Locatable, loc2 : Locatable)
    color = get_rgb(color)
    @lines << Line.new("", color, false, *loc1.xyz, *loc2.xyz)
  end

  def write_impl
    c 0xfe
    h 0x11

    s @name
    d @x
    d @y
    d @z
    d 65535
    d 65535
    d @points.size + @lines.size
    @points.each do |point|
      c 1
      s point.name
      color = point.color
      d color >> 16 & 0xff
      d color >> 8 & 0xff
      d color & 0xff
      d point.name_colored? ? 1 : 0
      l point
    end
    @lines.each do |line|
      c 2
      s line.name
      color = line.color
      d color >> 16 & 0xff
      d color >> 8 & 0xff
      d color & 0xff
      d line.name_colored? ? 1 : 0
      l line
      d line.x2
      d line.y2
      d line.z2
    end
  end

  private def get_rgb(color)
    case color
    when :RED
      0xFF0000
    when :GREEN
      0x00FF00
    else
      0x0000FF
    end
  end

  private class Point
    getter name, color, x, y, z
    getter? name_colored

    initializer name : String, color : Int32, name_colored : Bool, x : Int32,
      y : Int32, z : Int32
  end

  private class Line < Point
    getter x2, y2, z2

    def initialize(name : String, color : Int32, name_colored : Bool, x : Int32, y : Int32, z : Int32, x2 : Int32, y2 : Int32, z2 : Int32)
      super(name, color, name_colored, x, y, z)
      @x2, @y2, @z2 = x2, y2, z2
    end
  end
end
