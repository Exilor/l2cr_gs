class DimensionalRiftRoom
  @x_min : Int32
  @x_max : Int32
  @y_min : Int32
  @y_max : Int32

  getter type, room, teleport_coordinates
  getter spawns = [] of L2Spawn
  getter? boss_room
  property? party_inside : Bool = false

  def initialize(type : Int8, room : Int8, x_min : Int32, x_max : Int32, y_min : Int32, y_max : Int32, z_min : Int32, z_max : Int32, xt : Int32, yt : Int32, zt : Int32, boss_room : Bool)
    @type = type
    @room = room
    @z_min = z_min
    @z_max = z_max
    @boss_room = boss_room

    @x_min = x_min + 128
    @x_max = x_max - 128
    @y_min = y_min + 128
    @y_max = y_max - 128

    @teleport_coordinates = Location.new(xt, yt, zt)

    @s = Polygon.new(
      Int32.slice(x_min, x_max, x_max, x_min),
      Int32.slice(y_min, y_min, y_max, y_max),
      4
    )
  end

  def random_x : Int32
    Rnd.rand(@x_min..@x_max)
  end

  def random_y : Int32
    Rnd.rand(@y_min..@y_max)
  end

  def in_zone?(x : Int32, y : Int32, z : Int32) : Bool
    @s.contains?(x, y) && z.between?(@z_min, @z_max)
  end

  def spawn
    @spawns.each do |sp|
      sp.do_spawn
      sp.start_respawn
    end
  end

  def unspawn : self
    @spawns.each do |sp|
      sp.stop_respawn
      if last = sp.last_spawn
        last.delete_me
      end
    end

    self
  end
end
