class Packets::Outgoing::ExAirshipInfo < GameServerPacket
  @ship_id : Int32
  @fuel : Int32
  @max_fuel : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @heading : Int32
  @move_speed : Int32
  @rotation_speed : Int32
  @captain_id : Int32
  @helm_id : Int32

  def initialize(ship : L2AirshipInstance)
    @ship_id = ship.l2id
    @fuel = ship.fuel
    @max_fuel = ship.max_fuel
    @x, @y, @z = ship.xyz
    @heading = ship.heading
    @move_speed = ship.stat.move_speed.to_i
    @rotation_speed = ship.stat.rotation_speed.to_i
    @captain_id = ship.captain_id
    @helm_id = ship.helm_l2id
  end

  def write_impl
    c 0xfe
    h 0x60

    d @ship_id
    d @x
    d @y
    d @z
    d @heading

    d @captain_id
    d @move_speed
    d @rotation_speed
    d @helm_id

    if @helm_id != 0
      # L2J TODO: unhardcode
      d 0x16e # Controller X
      d 0x00 # Controller Y
      d 0x6b # Controller Z
      d 0x15c # Captain X
      d 0x00 # Captain Y
      d 0x69 # Captain Z
    else
      q 0
      q 0
      q 0
    end

    d @fuel
    d @max_fuel
  end
end
