require "../l2_vehicle"
require "../ai/l2_boat_ai"

class L2BoatInstance < L2Vehicle
  def initialize(template : L2CharTemplate)
    super
    ai
  end

  def instance_type : InstanceType
    InstanceType::L2BoatInstance
  end

  private def init_ai
    L2BoatAI.new(self)
  end

  def boat? : Bool
    true
  end

  def id : Int32
    0
  end

  def move_to_next_route_point : Bool
    if result = super
      broadcast_packet(VehicleDeparture.new(self))
    end

    result
  end

  def oust_player(pc : L2PcInstance)
    super

    loc = oust_loc

    if pc.online?
      pc.tele_to_location(*loc.xyz)
    else
      pc.set_xyz_invisible(*loc.xyz)
    end
  end

  def stop_move(loc : Location?, update : Bool)
    super

    broadcast_packet(VehicleStarted.new(self, 0))
    broadcast_packet(VehicleInfo.new(self))
  end

  def send_info(pc : L2PcInstance)
    pc.send_packet(VehicleInfo.new(self))
  end
end
