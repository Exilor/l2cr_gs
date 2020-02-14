require "./l2_character"
require "./known_list/vehicle_known_list"
require "./stat/vehicle_stat"
require "./ai/l2_vehicle_ai"
require "../vehicle_path_point"

class L2Vehicle < L2Character
  @engine : BoatEngine?
  @current_path : Array(VehiclePathPoint)? | Slice(VehiclePathPoint)?
  @run_state = 0

  getter passengers = Concurrent::Array(L2PcInstance).new
  setter oust_loc : Location?
  property dock_id : Int32 = 0

  def initialize(template : L2CharTemplate)
    super
    self.flying = true
  end

  def instance_type : InstanceType
    InstanceType::L2Vehicle
  end

  def boat? : Bool
    false
  end

  def airship? : Bool
    false
  end

  private def init_known_list
    @known_list = VehicleKnownList.new(self)
  end

  private def init_char_stat
    @stat = VehicleStat.new(self)
  end

  def stat : VehicleStat
    super.as(VehicleStat)
  end

  def in_dock? : Bool
    @dock_id > 0
  end

  def in_dock=(dock_id : Int32)
    @dock_id = dock_id
  end

  def oust_loc : Location
    @oust_loc ||
    MapRegionManager.get_tele_to_location(self, TeleportWhereType::TOWN)
  end

  def oust_players
    @passengers.safe_each { |pc| oust_player(pc) }
    @passengers.clear
  end

  def oust_player(pc : L2PcInstance)
    # debug "Kicking out #{pc.name}."
    pc.vehicle = nil
    pc.in_vehicle_position = nil
    remove_passenger(pc)
  end

  def add_passenger(pc : L2PcInstance) : Bool
    return false if @passengers.includes?(pc)
    return false if pc.vehicle && pc.vehicle != self
    @passengers << pc
    # debug "Added #{pc.name} to @passengers."
    true
  end

  def remove_passenger(pc : L2PcInstance)
    @passengers.delete_first(pc)
  end

  def empty? : Bool
    @passengers.empty?
  end

  def broadcast_to_passengers(gsp : GameServerPacket)
    @passengers.each &.send_packet(gsp)
  end

  def can_be_controlled? : Bool
    @engine.nil?
  end

  def register_engine(engine : BoatEngine)
    @engine = engine
  end

  def run_engine(delay : Int32)
    if engine = @engine
      ThreadPoolManager.schedule_general(engine, delay)
    end
  end

  def execute_path(path : Array(VehiclePathPoint) | Slice(VehiclePathPoint))
    @run_state = 0
    @current_path = path

    if path.empty?
      set_intention(AI::ACTIVE)
    else
      point = path[0]

      if point.move_speed > 0
        stat.move_speed = point.move_speed.to_f32
      end
      if point.rotation_speed > 0
        stat.rotation_speed = point.rotation_speed
      end

      set_intention(AI::MOVE_TO, Location.new(*point.xyz, 0))
    end
  end

  def move_to_next_route_point : Bool
    @move = nil

    if path = @current_path
      @run_state += 1
      if @run_state < path.size
        unless movement_disabled?
          point = path[@run_state]
          if point.move_speed == 0
            point.heading = point.rotation_speed
            tele_to_location(point, false)
            @current_path = nil
          else
            if point.move_speed > 0
              stat.move_speed = point.move_speed.to_f32
            end
            if point.rotation_speed > 0
              stat.rotation_speed = point.rotation_speed
            end

            m = MoveData.new
            m.disregarding_geodata = false
            m.on_geodata_path_index = -1
            m.x_destination = point.x
            m.y_destination = point.y
            m.z_destination = point.z
            m.heading = 0

            dist = Math.hypot(point.x - x, point.y - y)
            if dist > 1
              self.heading = Util.calculate_heading_from(x, y, point.x, point.y)
            end

            m.move_start_time = GameTimer.ticks
            @move = m
            GameTimer.register(self)

            return true
          end
        end
      else
        @current_path = nil
      end
    end

    run_engine(10)

    false
  end

  def pay_for_ride(item_id : Int32, count : Int64, oust_x : Int32, oust_y : Int32, oust_z : Int32)
    known_list.each_player(1000) do |pc|
      if pc.in_boat? && pc.boat == self
        if item_id > 0
          ticket = pc.inventory.get_item_by_item_id(item_id)

          if !ticket || !pc.inventory.destroy_item("Boat", ticket, count, pc, self)
            pc.send_packet(SystemMessageId::NOT_CORRECT_BOAT_TICKET)
            pc.tele_to_location(Location.new(oust_x, oust_y, oust_z), true)
            # This is custom. Without it, a player that has sailed but no longer
            # has the correct ticket will still be considered a passenger even
            # after being teleported away from the vehicle and will still be
            # moved along with it.
            remove_passenger(pc)
            #
            next
          end

          pc.send_packet(InventoryUpdate.modified(ticket))
        end

        add_passenger(pc)
      end
    end
  end

  def update_position : Bool
    result = super

    @passengers.reverse_each do |pc|
      if pc.vehicle == self
        # debug "#update_position updating the position of #{pc.name}."
        pc.set_xyz(*xyz)
        pc.revalidate_zone(false)
      end
    end

    result
  end

  def tele_to_location(loc : Locatable, allow_offset : Bool)
    stop_move(nil, false) if moving?
    self.teleporting = true
    set_intention(AI::ACTIVE)
    @passengers.each &.tele_to_location(loc, false)
    decay_me
    set_xyz(*loc.xyz)
    if loc.heading != 0
      self.heading = loc.heading
    end
    on_teleported
    revalidate_zone(true)
  end

  def stop_move(loc : Location?, update_known_objects : Bool)
    @move = nil

    if loc
      set_xyz(*loc.xyz)
      self.heading = loc.heading
      revalidate_zone(true)
    end

    if Config.move_based_knownlist && update_known_objects
      known_list.find_objects
    end
  end

  def delete_me
    @engine = nil
    begin
      stop_move(nil) if moving?
    rescue e
      error e
    end

    begin
      oust_players
    rescue e
      error e
    end

    old_region = world_region
    begin
      decay_me
    rescue e
      error e
    end

    begin
      old_region.try &.remove_from_zones(self)
    rescue e
      error e
    end

    begin
      @known_list.try &.remove_all_known_objects
    rescue e
      error e
    end

    L2World.remove_object(self)
    super
  end

  def update_abnormal_effect
    # no-op
  end

  def active_weapon_instance : L2ItemInstance?
    # return nil
  end

  def active_weapon_item : L2Weapon?
    # return nil
  end

  def secondary_weapon_instance : L2ItemInstance?
    # return nil
  end

  def secondary_weapon_item : L2Item?
    # return nil
  end

  def level : Int32
    0
  end

  def auto_attackable?(char : L2Character) : Bool
    false
  end

  def detach_ai
    # no-op
  end
end
