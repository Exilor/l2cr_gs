require "../models/airship_teleport_list"

module AirshipManager
  extend self
  extend Loggable
  include Packets::Outgoing

  private LOAD_DB = "SELECT * FROM airships"
  private ADD_DB = "INSERT INTO airships (owner_id,fuel) VALUES (?,?)"
  private UPDATE_DB = "UPDATE airships SET fuel=? WHERE owner_id=?"

  private AIRSHIPS_INFO = {} of Int32 => StatsSet
  private AIRSHIPS = {} of Int32 => L2AirshipInstance
  private TELEPORTS = {} of Int32 => AirshipTeleportList

  private TEMPLATE = L2CharTemplate.new StatsSet {
    "npcId" => 9,
    "level" => 0,
    # "jClass" => "boat",
    "baseSTR" => 0,
    "baseCON" => 0,
    "baseDEX" => 0,
    "baseINT" => 0,
    "baseWIT" => 0,
    "baseMEN" => 0,
    "baseShldDef" => 0,
    "baseShldRate" => 0,
    "baseAccCombat" => 38,
    "baseEvasRate" => 38,
    "baseCritRate" => 38,
    "collisionRadius" => 0,
    "collisionHeight" => 0,
    "sex" => "male",
    "type" => "",
    "baseAtkRange" => 0,
    "baseMpMax" => 0,
    "baseCpMax" => 0,
    "rewardExp" => 0,
    "rewardSp" => 0,
    "basePAtk" => 0,
    "baseMAtk" => 0,
    "basePAtkSpd" => 0,
    "aggroRange" => 0,
    "baseMAtkSpd" => 0,
    "rhand" => 0,
    "lhand" => 0,
    "armor" => 0,
    "baseWalkSpd" => 0,
    "baseRunSpd" => 0,
    "name" => "AirShip",
    "baseHpMax" => 50000,
    "baseHpReg" => 3e-3,
    "baseMpReg" => 3e-3,
    "basePDef" => 100,
    "baseMDef" => 100
  }

  def get_new_airship(x : Int32, y : Int32, z : Int32, heading : Int32) : L2AirshipInstance
    airship = L2AirshipInstance.new(TEMPLATE)
    airship.heading = heading
    airship.set_xyz_invisible(x, y, z)
    airship.spawn_me
    airship.stat.move_speed = 280
    airship.stat.rotation_speed = 2000
    airship
  end

  def get_new_airship(x : Int32, y : Int32, z : Int32, heading : Int32, owner_id : Int32) : L2AirshipInstance?
    info = AIRSHIPS_INFO.fetch(owner_id) { return }

    if airship = AIRSHIPS[owner_id]?
      airship.refresh_id
    else
      airship = L2ControllableAirshipInstance.new(TEMPLATE, owner_id)
      AIRSHIPS[owner_id] = airship
      airship.max_fuel = 600
      airship.fuel = info.get_i32("fuel")
      airship.stat.move_speed = 280
      airship.stat.rotation_speed = 2000
    end

    airship.heading = heading
    airship.set_xyz_invisible(x, y, z)
    airship.spawn_me

    airship
  end

  def remove_airship(ship : L2AirshipInstance)
    if ship.owner_id != 0
      store_in_db(ship.owner_id)
      if info = AIRSHIPS_INFO[ship.owner_id]?
        info["fuel"] = ship.fuel
      end
    end
  end

  def has_airship_license?(owner_id : Int32) : Bool
    AIRSHIPS_INFO.has_key?(owner_id)
  end

  def register_license(owner_id : Int32)
    if AIRSHIPS_INFO.has_key?(owner_id)
      return
    end

    info = StatsSet {"fuel" => 600}
    AIRSHIPS_INFO[owner_id] = info

    begin
      GameDB.exec(ADD_DB, owner_id, info.get_i32("fuel"))
    rescue e
      error e
    end
  end

  def has_airship?(owner_id : Int32) : Bool
    return false unless ship = AIRSHIPS[owner_id]?
    ship.visible? || ship.teleporting?
  end

  def register_airship_teleport_list(dock_id : Int32, location_id : Int32, tp : Slice(Slice(VehiclePathPoint)), fuel_consumption : Slice(Int32))
    if tp.size != fuel_consumption.size
      warn { "tp.size (#{tp.size}) != fuel_consumption.size (#{fuel_consumption.size})" }
      return
    end

    TELEPORTS[dock_id] = AirshipTeleportList.new(location_id, fuel_consumption, tp)
  end

  def send_airship_teleport_list(pc : L2PcInstance)
    unless ship = pc.airship
      return
    end

    if !ship.captain?(pc) || !ship.in_dock? || ship.moving?
      return
    end

    dock_id = ship.dock_id

    unless all = TELEPORTS[dock_id]?
      return
    end

    packet = ExAirShipTeleportList.new(all.location, all.routes, all.fuel)
    pc.send_packet(packet)
  end

  def get_fuel_consumption(dock_id : Int32, index : Int32) : Int32
    unless all = TELEPORTS[dock_id]?
      return 0
    end

    if index < -1 || index >= all.fuel.size
      return 0
    end

    all.fuel[index + 1]
  end

  def load
    GameDB.each(LOAD_DB) do |rs|
      info = StatsSet {"fuel" => rs.get_i32("fuel")}
      AIRSHIPS_INFO[rs.get_i32("owner_id")] = info
    end

    info { "Loaded #{AIRSHIPS_INFO.size} private airships." }
  rescue e
    error e
  end

  def get_teleport_destination(dock_id : Int32, index : Int32) : Slice(VehiclePathPoint)?
    unless all = TELEPORTS[dock_id]?
      return
    end

    if index < -1 || index >= all.routes.size
      return
    end

    # all.routes[index + 1]
    all.routes.unsafe_fetch(index + 1)
  end

  private def store_in_db(owner_id)
    unless info = AIRSHIPS_INFO[owner_id]?
      return
    end

    begin
      GameDB.exec(UPDATE_DB, info.get_i32("fuel"), owner_id)
    rescue e
      error e
    end
  end
end
