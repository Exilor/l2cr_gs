require "../ai/l2_airship_ai"

class L2AirshipInstance < L2Vehicle
  def initialize(template : L2CharTemplate)
    super
    ai
  end

  def instance_type : InstanceType
    InstanceType::L2AirShipInstance
  end

  private def init_ai : L2CharacterAI
    L2AirshipAI.new(self)
  end

  def airship? : Bool
    true
  end

  def owner_id : Int32
    0
  end

  def owner?(pc : L2PcInstance) : Bool
    false
  end

  def captain_id : Int32
    0
  end

  def helm_l2id : Int32
    0
  end

  def helm_item_id : Int32
    0
  end

  def set_captain(pc : L2PcInstance?) : Bool
    false
  end

  def captain?(pc : L2PcInstance) : Bool
    false
  end

  def fuel : Int32
    0
  end

  def fuel=(fuel : Int32)
    # no-op
  end

  def id : Int32
    0
  end

  def max_fuel : Int32
    0
  end

  def max_fuel=(max : Int32)
    # no-op
  end

  def stop_move(loc : Location?, update : Bool)
    super
    broadcast_packet(ExStopMoveAirship.new(self))
  end

  def send_info(pc : L2PcInstance)
    if visible_for?(pc)
      pc.send_packet(ExAirshipInfo.new(self))
    end
  end

  def move_to_next_route_point : Bool
    result = super

    if result
      broadcast_packet(ExMoveToLocationAirship.new(self))
    end

    result
  end

  def add_passenger(pc : L2PcInstance) : Bool
    return false unless super

    pc.vehicle = self
    pc.in_vehicle_position = Location.new(0, 0, 0)
    pc.broadcast_packet(ExGetOnAirship.new(pc, self))
    pc.known_list.remove_all_known_objects
    pc.set_xyz(*xyz)
    pc.revalidate_zone(true)
    # Without this the character attempts to go back to where he boarded the
    # airship before he was teleported into it. This also happens in L2J.
    pc.stop_move(nil)

    true
  end

  def oust_player(pc : L2PcInstance)
    super

    loc = oust_loc

    if pc.online?
      pc.broadcast_packet(ExGetOffAirship.new(pc, self, *loc.xyz))
      pc.known_list.remove_all_known_objects
      pc.set_xyz(loc)
      pc.revalidate_zone(true)
    else
      pc.set_xyz_invisible(*loc.xyz)
    end
  end

  def delete_me : Bool
    return false unless super

    AirshipManager.remove_airship(self)

    true
  end

  def update_abnormal_effect
    broadcast_packet(ExAirshipInfo.new(self))
  end
end
