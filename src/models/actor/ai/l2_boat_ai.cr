require "./l2_vehicle_ai"

class L2BoatAI < L2VehicleAI
  def move_to(x : Int32, y : Int32, z : Int32)
    unless @actor.movement_disabled?
      unless @client_moving
        @actor.broadcast_packet(VehicleStarted.new(actor, 1))
      end

      @client_moving = true
      @actor.move_to_location(x, y, z, 0)
      @actor.broadcast_packet(VehicleDeparture.new(actor))
    end
  end

  def client_stop_moving(loc : Location?)
    if @actor.moving?
      @actor.stop_move(loc)
    end

    if @client_moving || loc
      @client_moving = false
      @actor.broadcast_packet(VehicleStarted.new(actor, 0))
      @actor.broadcast_packet(VehicleInfo.new(actor))
    end
  end

  def describe_state_to_player(pc : L2PcInstance)
    if @client_moving
      pc.send_packet(VehicleDeparture.new(actor))
    end
  end

  def actor
    @actor.as(L2BoatInstance)
  end
end
