require "./l2_vehicle_ai"

class L2AirshipAI < L2VehicleAI
  def move_to(x : Int32, y : Int32, z : Int32)
    unless @actor.movement_disabled?
      @client_moving = true
      @actor.move_to_location(x, y, z, 0)
      @actor.broadcast_packet(ExMoveToLocationAirship.new(@actor))
    end
  end

  def client_stop_moving(loc : Location?)
    if @actor.moving?
      @actor.stop_move(loc)
    end

    if @client_moving || loc
      @client_moving = false
      @actor.broadcast_packet(ExStopMoveAirship.new(@actor))
    end
  end

  def describe_state_to_player(pc : L2PcInstance)
    if @client_moving
      pc.send_packet(ExMoveToLocationAirship.new(@actor))
    end
  end
end
