require "../models/actor/instance/l2_boat_instance"

module BoatManager
  extend self
  extend Loggable

  private BOATS = Concurrent::Map(Int32, L2BoatInstance).new
  private BUSY_DOCKS = Slice.new(3, false)

  TALKING_ISLAND = 0
  GLUDIN_HARBOR = 1
  RUNE_HARBOR = 2

  def load
    boat = get_new_boat(2, 48950, 190613, -3610, 60800)
    boat.register_engine(BoatGiranTalking.new(boat))
    boat.run_engine(180_000)

    boat = get_new_boat(3, -95686, 150514, -3610, 16723)
    boat.register_engine(BoatGludinRune.new(boat))
    boat.run_engine(180_000)
    dock_ship(GLUDIN_HARBOR, true)

    boat = get_new_boat(4, 111264, 226240, -3610, 32768)
    boat.register_engine(BoatInnadrilTour.new(boat))
    boat.run_engine(180_000)

    boat = get_new_boat(5, 34381, -37680, -3610, 40785)
    boat.register_engine(BoatRunePrimeval.new(boat))
    boat.run_engine(180_000)
    dock_ship(RUNE_HARBOR, true)

    boat = get_new_boat(1, -96622, 261660, -3610, 32768)
    boat.register_engine(BoatTalkingGludin.new(boat))
    boat.run_engine(180_000)
    dock_ship(TALKING_ISLAND, true)
  end

  def get_new_boat(boat_id : Int32, x : Int32, y : Int32, z : Int32, heading : Int32) : L2BoatInstance
    set = StatsSet.new
    set["npcId"] = boat_id
    set["level"] = 0
    set["jClass"] = "boat"

    set["baseSTR"] = 0
    set["baseCON"] = 0
    set["baseDEX"] = 0
    set["baseINT"] = 0
    set["baseWIT"] = 0
    set["baseMEN"] = 0

    set["baseShldDef"] = 0
    set["baseShldRate"] = 0
    set["baseAccCombat"] = 38
    set["baseEvasRate"] = 38
    set["baseCritRate"] = 38

    set["collision_radius"] = 0
    set["collision_height"] = 0
    set["sex"] = "male"
    set["type"] = ""
    set["baseAtkRange"] = 0
    set["baseMpMax"] = 0
    set["baseCpMax"] = 0
    set["rewardExp"] = 0
    set["rewardSp"] = 0
    set["basePAtk"] = 0
    set["baseMAtk"] = 0
    set["basePAtkSpd"] = 0
    set["aggroRange"] = 0
    set["baseMAtkSpd"] = 0
    set["rhand"] = 0
    set["lhand"] = 0
    set["armor"] = 0
    set["baseWalkSpd"] = 0
    set["baseRunSpd"] = 0
    set["baseHpMax"] = 50000
    set["baseHpReg"] = 3e-3
    set["baseMpReg"] = 3e-3
    set["basePDef"] = 100
    set["baseMDef"] = 100

    template = L2CharTemplate.new(set)
    boat = L2BoatInstance.new(template)
    boat.heading = heading
    boat.set_xyz_invisible(x, y, z)
    boat.spawn_me
    BOATS[boat.l2id] = boat
  end

  def [](id : Int) : L2BoatInstance
    BOATS[id]
  end

  def []?(id : Int) : L2BoatInstance?
    BOATS[id]?
  end

  def dock_ship(h : Int, val : Bool)
    if BUSY_DOCKS[h]?.nil?
      debug "index #{h} out of bounds"
    else
      BUSY_DOCKS[h] = val
    end
  end

  def dock_busy?(h : Int) : Bool
    ret = BUSY_DOCKS[h]?
    if ret.nil?
      debug "index #{h} out of bounds"
      false
    else
      ret
    end
  end

  def broadcast_packets(point1 : VehiclePathPoint, point2 : VehiclePathPoint, *packets)
    L2World.players.each do |pc|
      dx = pc.x - point1.x
      dy = pc.y - point1.y
      if Math.hypot(dx, dy) < Config.boat_broadcast_radius
        packets.each { |packet| pc.send_packet(packet) }
      else
        dx = pc.x - point2.x
        dy = pc.y - point2.y
        if Math.hypot(dx, dy) < Config.boat_broadcast_radius
          packets.each { |packet| pc.send_packet(packet) }
        end
      end
    end
  end
end
